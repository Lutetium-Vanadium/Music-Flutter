import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:focused_menu/modals.dart";

import "package:Music/bloc/data_bloc.dart";
import "package:Music/bloc/queue_bloc.dart";
import "package:Music/constants.dart";
import "package:Music/helpers/db.dart";
import "package:Music/helpers/generateSubtitle.dart";
import "package:Music/models/models.dart";
import "package:Music/routes/widgets/CoverImage.dart";

class Artists extends StatefulWidget {
  @override
  _ArtistsState createState() => _ArtistsState();
}

class _ArtistsState extends State<Artists> {
  List<ArtistData> _artists = [];

  @override
  void initState() {
    super.initState();
    getArtists();
  }

  getArtists() async {
    var db = await getDB();

    var preSongs = PreArtist.fromMapArray(await db.rawQuery(
        "SELECT artist as name, COUNT(*) as numSongs FROM songdata GROUP BY artist;"));

    List<ArtistData> artists = [];

    for (var preSong in preSongs) {
      var images = await db.query(
        Tables.Albums,
        where: "artist LIKE ?",
        whereArgs: [preSong.name],
        columns: ["imagePath"],
        orderBy: "numSongs DESC",
        limit: 4,
      );

      artists.add(ArtistData.fromMapAndPreArtist(images, preSong));
    }

    if (!mounted) return;

    setState(() {
      _artists = artists;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width10 = MediaQuery.of(context).size.shortestSide / 10;

    return MultiBlocListener(
      listeners: [
        BlocListener<DataBloc, DataState>(
          listener: (_, state) {
            if (state is UpdateData) {
              getArtists();
            }
          },
        ),
        BlocListener<QueueBloc, QueueState>(
          listener: (_, state) {
            if (state.updateData) {
              getArtists();
            }
          },
        ),
      ],
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.only(left: width10 / 4 * 2, top: 30, bottom: 7),
              child:
                  Text("Artists", style: Theme.of(context).textTheme.headline3),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(0.3 * width10),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: (4.1 * width10) / (4.1 * width10 + 3 * rem),
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var artist = _artists[index];

                  var mozaic = artist.images.length == 4;

                  return CoverImage(
                    image: mozaic ? null : artist.images[0],
                    images: mozaic ? artist.images : null,
                    title: artist.name,
                    subtitle: generateSubtitle(
                        type: "Artist", numSongs: artist.numSongs),
                    isBig: true,
                    tag: artist.name,
                    onClick: () {
                      Navigator.of(context)
                          .pushNamed("/artist", arguments: artist);
                    },
                    focusedMenuItems: [
                      FocusedMenuItem(
                        onPressed: () async {
                          var db = await getDB();
                          var songs = SongData.fromMapArray(await db.query(
                            Tables.Songs,
                            where: "artist LIKE ?",
                            whereArgs: [artist.name],
                            orderBy: "LOWER(title), title",
                          ));
                          BlocProvider.of<QueueBloc>(context)
                              .add(EnqueueSongs(songs: songs));
                        },
                        title: Text("Play"),
                        trailingIcon: Icon(Icons.playlist_play),
                        backgroundColor: Colors.transparent,
                      ),
                    ],
                  );
                },
                childCount: _artists.length,
              ),
            ),
          )
        ],
      ),
    );
  }
}
