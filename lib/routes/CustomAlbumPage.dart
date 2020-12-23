import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:music/global_providers/database.dart';
import 'package:music/constants.dart';
import 'package:music/bloc/data_bloc.dart';
import 'package:music/bloc/queue_bloc.dart';
import 'package:music/helpers/generateSubtitle.dart';
import 'package:music/models/models.dart';
import './widgets/SongPage.dart';

class CustomAlbumPage extends StatefulWidget {
  final CustomAlbumData album;

  const CustomAlbumPage(this.album, {Key key}) : super(key: key);

  @override
  _CustomAlbumPageState createState() => _CustomAlbumPageState();
}

class _CustomAlbumPageState extends State<CustomAlbumPage>
    with SingleTickerProviderStateMixin {
  List<SongData> _songs = [];
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    beginAnimation();
    getSongs();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> beginAnimation() async {
    await Future.delayed(const Duration(milliseconds: 450));
    await _controller.forward();
  }

  Future<void> getSongs() async {
    try {
      var db = DatabaseProvider.getDB(context);

      String songNames = stringifyArr((await db.getCustomAlbums(
        where: 'id LIKE ?',
        whereArgs: [widget.album.id],
      ))[0]
          .songs);

      var songs = await db.getSongs(where: 'title IN ($songNames)');

      if (!mounted) return;

      setState(() {
        _songs = songs;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return MultiBlocListener(
      listeners: [
        BlocListener<DataBloc, DataState>(
          listener: (_, state) {
            if (state is UpdateData) {
              getSongs();
            }
          },
        ),
        BlocListener<QueueBloc, QueueState>(
          listener: (context, state) {
            if (state.updateData) {
              getSongs();
            }
          },
        ),
      ],
      child: SongPage(
        controller: _controller,
        title: widget.album.name,
        subtitle: generateSubtitle(type: 'Album', numSongs: _songs.length),
        hero: Hero(
          tag: widget.album.id,
          child: Image.asset(
            '$imgs/music_symbol.png',
            width: screenWidth,
            height: screenWidth,
            fit: BoxFit.cover,
          ),
        ),
        songs: _songs,
        customAlbum: widget.album,
      ),
    );
  }
}
