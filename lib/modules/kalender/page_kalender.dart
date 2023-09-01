import 'dart:math';

import 'package:absentip/data/apis/api_connect.dart';
import 'package:absentip/data/apis/api_response.dart';
import 'package:absentip/data/apis/end_point.dart';
import 'package:absentip/data/enums/api_status.dart';
import 'package:absentip/data/enums/request_method.dart';
import 'package:absentip/model/key_value_model.dart';
import 'package:absentip/utils/app_color.dart';
import 'package:absentip/utils/app_images.dart';
import 'package:absentip/utils/constants.dart';
import 'package:absentip/utils/helpers.dart';
import 'package:absentip/wigets/appbar_widget.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week_of_year/week_of_year.dart';

class PageKalender extends StatefulWidget {
  const PageKalender({Key? key}) : super(key: key);

  @override
  State<PageKalender> createState() => _PageKalenderState();
}

class _PageKalenderState extends State<PageKalender> {
  final _eventController = EventController();
  final _apiResponse = ApiResponse();
  String _selectedCalendar = "bulan";
  final List _viewCalendar = [
    KeyValueModel(key: "bulan", value: "Lihat Bunan"),
    KeyValueModel(key: "minggu", value: "Lihat Minggu"),
    KeyValueModel(key: "hari", value: "Lihat Hari"),
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getEvent();
    });

    super.initState();
  }

  Future<void> getEvent() async {
    setState(() {
      _apiResponse.setApiSatatus = ApiStatus.loading;
    });

    final pref = await SharedPreferences.getInstance();
    final response = await ApiConnect.instance.request(
      requestMethod: RequestMethod.post,
      url: EndPoint.event,
      params: {
        'token_auth': pref.getString(TOKEN_AUTH).toString(),
        'hash_user': pref.getString(HASH_USER).toString(),
      },
    );

    if (response != null) {
      if (response['success']) {
        if (mounted) {
          setState(() {
            _apiResponse.setApiSatatus = ApiStatus.success;
            _apiResponse.setData = response['data'];
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _apiResponse.setApiSatatus = ApiStatus.empty;
            _apiResponse.setMessage = response['message'].toString();
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _apiResponse.setApiSatatus = ApiStatus.failed;
          _apiResponse.setMessage = "Terjadi kesalahan";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Kalender Kegiatan", action: [
        PopupMenuButton<String>(
          color: Colors.white,
          icon: Icon(
            MdiIcons.dotsVertical,
            color: Colors.white,
          ),
          onSelected: (value) {
            setState(() {
              _selectedCalendar = value;
            });
          },
          itemBuilder: (BuildContext context) {
            return _viewCalendar
                .map((e) => PopupMenuItem<String>(
                      value: e.key,
                      child: Text(e.value),
                    ))
                .toList();
          },
        ),
      ]),
      body: Builder(
        builder: (context) {
          if (_apiResponse.getApiStatus == ApiStatus.success) {
            List listEvent = _apiResponse.getData;
            for (var event in listEvent) {
              Color color = Colors.white;
              if (event['jenis_event'].toString() == '1') {
                color = const Color(0xFFe51c23);
              } else if (event['jenis_event'].toString() == '2') {
                color = const Color(0xFF4CAF50);
              } else {
                color = const Color(0xFFf8b195);
              }
              _eventController.add(
                CalendarEventData(
                  date: DateFormat("yyyy-MM-dd hh:mm:ss").parse(event['tgl_event'].toString() + " " + event['jam_mulai_event'].toString()),
                  endDate: DateFormat("yyyy-MM-dd hh:mm:ss").parse(event['tgl_event'].toString() + " " + event['jam_selesai_event'].toString()),
                  startTime: DateFormat("yyyy-MM-dd hh:mm:ss").parse(event['tgl_event'].toString() + " " + event['jam_mulai_event'].toString()),
                  endTime: DateFormat("yyyy-MM-dd hh:mm:ss").parse(event['tgl_event'].toString() + " " + event['jam_selesai_event'].toString()),
                  event: event,
                  title: event['nama_event'].toString(),
                  color: color,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            if (_selectedCalendar == "minggu") {
              return viewMinggu();
            } else if (_selectedCalendar == "hari") {
              return viewHari();
            } else {
              return viewBulan();
            }
          } else if (_apiResponse.getApiStatus == ApiStatus.loading) {
            return loadingWidget();
          } else {
            return emptyWidget(_apiResponse.getMessage);
          }
        },
      ),
    );
  }

  DayView<Object?> viewHari() {
    return DayView(
      controller: _eventController,
      dayTitleBuilder: (date) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: AppColor.hitam),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              parseDateInd(date.toString(), "dd MMMM yyyy"),
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        );
      },
      timeStringBuilder: (date, {secondaryDate}) {
        return parseDateInd(date.toString(), "HH:mm");
      },
      onEventTap: (events, date) {
        if (events.isNotEmpty) {
          List listEvent = [];

          for (var element in events) {
            if (element.event != null) {
              listEvent.add(element.event);
            }
          }

          if (listEvent.isNotEmpty) {
            detailEvent(listEvent);
          }
        }
      },
    );
  }

  WeekView<Object?> viewMinggu() {
    return WeekView(
      controller: _eventController,
      weekPageHeaderBuilder: (startDate, endDate) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: AppColor.hitam),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              parseDateInd(startDate.toString(), "dd MMM yyyy") + " s/d " + parseDateInd(endDate.toString(), "dd MMM yyyy"),
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        );
      },
      weekDayBuilder: (date) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(width: 0.7, color: Colors.grey.shade400),
          ),
          child: Column(
            children: [
              Text(
                parseDateInd(date.toString(), "EEE"),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                parseDateInd(date.toString(), "dd"),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
      weekNumberBuilder: (firstDayOfWeek) {
        return Center(
          child: Text(
            firstDayOfWeek.weekOfYear.toString(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
      timeLineStringBuilder: (date, {secondaryDate}) {
        return parseDateInd(date.toString(), "HH:mm");
      },
      onEventTap: (events, date) {
        if (events.isNotEmpty) {
          List listEvent = [];

          for (var element in events) {
            if (element.event != null) {
              listEvent.add(element.event);
            }
          }

          if (listEvent.isNotEmpty) {
            detailEvent(listEvent);
          }
        }
      },
    );
  }

  MonthView<Object?> viewBulan() {
    return MonthView(
      controller: _eventController,
      headerBuilder: (date) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: AppColor.hitam),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              parseDateInd(date.toString(), "MMMM yyyy"),
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        );
      },
      weekDayBuilder: (day) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(width: 0.7, color: Colors.grey.shade400),
          ),
          child: Text(
            namaHari(day),
            textAlign: TextAlign.center,
          ),
        );
      },
      minMonth: DateTime(2020),
      maxMonth: DateTime(2050),
      initialMonth: DateTime.now(),
      cellAspectRatio: 1,
      startDay: WeekDays.monday,
      onEventTap: (event, date) {
        if (event.event != null) {
          detailEvent([event.event]);
        }
      },
    );
  }

  void detailEvent(List listEvent) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        child: Card(
          margin: const EdgeInsets.all(0),
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      AppImages.logoGold,
                      width: 40,
                      color: AppColor.biru2,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Detail Event',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 1),
                Column(
                  children: listEvent
                      .map(
                        (event) => Column(
                          children: [
                            const SizedBox(height: 8),
                            itemDetail(true, "Nama Event", event['nama_event'].toString()),
                            itemDetail(false, "Tanggal", parseDateInd(event['tgl_event'].toString(), "dd MMMM yyyy")),
                            itemDetail(true, "Waktu Mulai", parseDateInd(event['jam_mulai_event'].toString(), "HH:mm") + " WIB"),
                            itemDetail(false, "Waktu Selesai", parseDateInd(event['jam_selesai_event'].toString(), "HH:mm") + " WIB"),
                            itemDetail(true, "Jenis Event", event['ket_jenis_event'].toString()),
                            itemDetail(false, "Keterangan", event['keterangan'].toString()),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget itemDetail(bool isColor, String title, String value) {
    return Container(
      color: isColor ? AppColor.biru.withAlpha(50) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String namaHari(int hari) {
    switch (hari) {
      case 0:
        return "Sen";
      case 1:
        return "Sel";
      case 2:
        return "Rab";
      case 3:
        return "Kam";
      case 4:
        return "Jum";
      case 5:
        return "Sab";
      case 6:
        return "Min";
      default:
        return "";
    }
  }
}
