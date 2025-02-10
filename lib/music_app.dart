import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MusicApp extends StatefulWidget {
  const MusicApp({Key? key}) : super(key: key);

  @override
  _MusicAppState createState() => _MusicAppState();
}

class _MusicAppState extends State<MusicApp> {
  List<dynamic>? chapters;

  loadData() async {
    var data = await rootBundle.loadString("surah/quran_all_surah_list.json");
    Map<String, dynamic> quranSurah = await jsonDecode(data);
    chapters = await quranSurah["chapters"];
    setState(() {});
  }

  @override
  void initState() {
    loadData();
    // TODO: implement initState
    super.initState();
  }

  String currentTitle = "";
  String currentArtist = "";
  String currentCover = "";
  String currentSong = "";
  IconData btnIcon = Icons.play_arrow;

  AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration musicDuration = Duration();
  Duration musicPosition = Duration();

  playMusic(String url) async {
    if (isPlaying && currentSong != url) {
      _audioPlayer.pause();
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        currentSong = url;
      });
    } else if (!isPlaying) {
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        isPlaying = true;
        btnIcon = Icons.pause;
      });
    }

    _audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        musicDuration = event;
      });
    });

    _audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        musicPosition = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff3C415C),
              Color(0xff232323),
            ],
          ),
        ),
        child: SafeArea(
          child: chapters != null
              ? Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        print(chapters);
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        color: Colors.green,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: chapters!.length,
                        itemBuilder: (context, index) => InkWell(
                          onTap: () {
                            print(chapters);
                            var fileName = "";
                            if (index < 9) {
                              fileName = "http://opsonin.com.bd/ramadan/surah/00${index + 1}.mp3";
                            } else if (index < 99) {
                              fileName = "http://opsonin.com.bd/ramadan/surah/0${index + 1}.mp3";
                            } else {
                              fileName = "http://opsonin.com.bd/ramadan/surah/${index + 1}.mp3";
                            }
                            playMusic(fileName);
                            setState(() {
                              currentTitle = chapters![index]["bn_name"];
                              currentArtist = chapters![index]["type"];
                              currentCover = chapters![index]["verse_count"];
                            });
                          },
                          child: ListTile(
                            title: Text(
                              chapters![index]["bn_name"],
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              chapters![index]["verse_count"],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            trailing: Container(
                              margin: EdgeInsets.all(17.0),
                              child: Icon(
                                Icons.music_note,
                                color: Colors.blueGrey.shade200,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    currentCover != ""
                        ? Column(
                            children: [
                              Container(
                                color: Colors.white,
                                height: 1.0,
                              ),
                              ListTile(
                                title: Text(
                                  currentTitle,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  currentArtist,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                                trailing: Container(
                                  height: 40.0,
                                  width: 40.0,
                                  margin: EdgeInsets.all(7.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      if (isPlaying) {
                                        _audioPlayer.pause();
                                        setState(() {
                                          btnIcon = Icons.play_arrow;
                                          isPlaying = false;
                                        });
                                      } else {
                                        _audioPlayer.resume();

                                        setState(() {
                                          btnIcon = Icons.pause;
                                          isPlaying = true;
                                        });
                                      }
                                    },
                                    icon: Icon(
                                      btnIcon,
                                      size: 26,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 22.0,
                                  right: 30.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "${musicPosition.inMinutes}:${musicPosition.inSeconds.remainder(60)}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w200,
                                      ),
                                    ),
                                    Text(
                                      "${musicDuration.inMinutes}:${musicDuration.inSeconds.remainder(60)}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w200,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                  ],
                )
              : SizedBox.shrink(),
        ),
      ),
    );
  }
}
