import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'model/tryout.dart';
import 'page_detail_tryout.dart';

Widget widgetItemTryout(BuildContext context, Tryout tryout) {

  return InkWell(
    child: Card(
      elevation: 6,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tryout.namaTryout, style: const TextStyle(fontWeight: FontWeight.bold),),
            const SizedBox(height: 5,),
            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text("Mulai", style: TextStyle(fontSize: 12),),
                ),
                const SizedBox(width: 5,),
                const Text(":", style: TextStyle(fontSize: 12),),
                const SizedBox(width: 5,),
                Expanded(
                  flex: 3,
                  child: Text(tryout.waktuMulai, style: GoogleFonts.ptMono(fontSize: 12),),
                ),
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text("Selesai", style: TextStyle(fontSize: 12),),
                ),
                const SizedBox(width: 5,),
                const Text(":", style: TextStyle(fontSize: 12),),
                const SizedBox(width: 5,),
                Expanded(
                  flex: 3,
                  child: Text(tryout.waktuSelesai, style: GoogleFonts.ptMono(fontSize: 12),),
                ),
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text("Jumlah soal", style: TextStyle(fontSize: 12),),
                ),
                const SizedBox(width: 5,),
                const Text(":", style: TextStyle(fontSize: 12),),
                const SizedBox(width: 5,),
                Expanded(
                  flex: 3,
                  child: Text(tryout.jumlahSoal, style: GoogleFonts.ptMono(fontSize: 12),),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            const Divider(height: 1, color: Colors.black54,),
            const SizedBox(height: 10,),
            Row(
              children: [
                Expanded(child: Text(tryout.absenTryout.bisaAbsen, style: const TextStyle(fontSize: 12),)),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.hourglass_top_rounded, size: 20,),
                      const SizedBox(width: 5,),
                      Text("${tryout.waktu} menit", textAlign: TextAlign.end, style: const TextStyle(fontSize: 12),),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => PageDetailTryout(tryout: tryout,)));
    },
  );

}