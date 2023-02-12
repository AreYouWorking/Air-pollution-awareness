import 'package:app/Camera.dart';
import 'package:app/main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class Memory extends StatefulWidget {
  const Memory({super.key});

  @override
  State<Memory> createState() => _MemoryState();
}

class _MemoryState extends State<Memory> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Center(
          child: Column(
        children: [
          InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Camera()),
                );
              },
              child: Container(
                width: 330,
                height: 175,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15), color: greyUI),
                child: const Icon(
                  Icons.camera_alt,
                  size: 50,
                ),
              )),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              child: Column(children: [
                const Text("Memory", textScaleFactor: 1.5),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    height: 400,
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: List.generate(20, (index) {
                        return Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: greyUI),
                          margin: const EdgeInsets.all(5),
                          width: 100,
                          height: 200,
                        );
                      }),
                    ),
                  ),
                )
              ]),
            ),
          )
        ],
      )),
    );
  }
}
