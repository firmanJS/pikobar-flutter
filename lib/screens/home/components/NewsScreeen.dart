import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pikobar_flutter/blocs/news/newsList/Bloc.dart';
import 'package:pikobar_flutter/components/RoundedButton.dart';
import 'package:pikobar_flutter/components/Skeleton.dart';
import 'package:pikobar_flutter/constants/Analytics.dart';
import 'package:pikobar_flutter/constants/Colors.dart';
import 'package:pikobar_flutter/constants/Dictionary.dart';
import 'package:pikobar_flutter/constants/collections.dart';
import 'package:pikobar_flutter/environment/Environment.dart';
import 'package:pikobar_flutter/models/NewsModel.dart';
import 'package:pikobar_flutter/screens/news/News.dart';
import 'package:pikobar_flutter/screens/news/NewsDetailScreen.dart';
import 'package:pikobar_flutter/utilities/AnalyticsHelper.dart';
import 'package:pikobar_flutter/utilities/FormatDate.dart';

class NewsScreen extends StatefulWidget {
  final String news;
  final int maxLength;

  NewsScreen({@required this.news, this.maxLength});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsListBloc, NewsListState>(
      builder: (context, state) {
        return state is NewsListLoaded ? widget.maxLength != null
            ? _buildContent(state.newsList)
            : _buildContentList(state.newsList) : _buildLoading();
      },
    );
  }

  _buildContent(List<NewsModel> list) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: EdgeInsets.only(bottom: 10.0),
        elevation: 3.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: list.length > 3
                    ? 3
                    : list.length,
                padding: const EdgeInsets.only(bottom: 10.0),
                itemBuilder: (BuildContext context, int index) {
                  return designNewsHome(list[index]);
                },
                separatorBuilder: (BuildContext context, int dex) => Divider()),
            Container(
              margin: EdgeInsets.only(bottom: 20, top: 5),
              padding: EdgeInsets.only(left: 10, right: 10),
              child: RoundedButton(
                  height: 60,
                  minWidth: MediaQuery.of(context).size.width,
                  title: Dictionary.more,
                  borderRadius: BorderRadius.circular(5.0),
                  color: ColorBase.green,
                  textStyle: Theme.of(context).textTheme.subhead.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsListScreen(news: widget.news),
                      ),
                    );

                    AnalyticsHelper.setLogEvent(Analytics.tappedMore);
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget designNewsHome(NewsModel data) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
          elevation: 0,
          color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NewsDetailScreen(id: data.id, news: widget.news),
              ),
            );

            AnalyticsHelper.setLogEvent(Analytics.tappedNewsDetail,
                <String, dynamic>{'title': data.title});
          },
          child: Container(
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 70,
                  height: 70,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: data.image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                          heightFactor: 4.2,
                          child: CupertinoActivityIndicator()),
                      errorWidget: (context, url, error) => Container(
                          height: MediaQuery.of(context).size.height / 3.3,
                          color: Colors.grey[200],
                          child: Image.asset(
                              '${Environment.iconAssets}pikobar.png',
                              fit: BoxFit.fitWidth)),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  width: MediaQuery.of(context).size.width - 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        data.title,
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                          padding: EdgeInsets.only(top: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Image.network(
                                    data.newsChannelIcon,
                                    width: 25.0,
                                    height: 25.0,
                                  ),
                                  SizedBox(width: 3.0),
                                  Text(
                                    data.newsChannel,
                                    style: TextStyle(
                                        fontSize: 12.0, color: Colors.grey),
                                  ),
                                ],
                              ),
                              Text(
                                unixTimeStampToDate(
                                    data.publishedAt),
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.grey),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget designListNews(NewsModel data) {
    return Card(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
          elevation: 0,
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.only(left: 5, right: 5, top: 17, bottom: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 70,
                  height: 70,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: data.image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                          heightFactor: 4.2,
                          child: CupertinoActivityIndicator()),
                      errorWidget: (context, url, error) => Container(
                          height: MediaQuery.of(context).size.height / 3.3,
                          color: Colors.grey[200],
                          child: Image.asset(
                              '${Environment.iconAssets}pikobar.png',
                              fit: BoxFit.fitWidth)),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  width: MediaQuery.of(context).size.width - 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        data.title,
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                          padding: EdgeInsets.only(top: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Image.network(
                                    data.newsChannelIcon,
                                    width: 25.0,
                                    height: 25.0,
                                  ),
                                  SizedBox(width: 3.0),
                                  Text(
                                    data.newsChannel,
                                    style: TextStyle(
                                        fontSize: 12.0, color: Colors.grey),
                                  ),
                                ],
                              ),
                              Text(
                                unixTimeStampToDate(
                                    data.publishedAt),
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.grey),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NewsDetailScreen(id: data.id, news: widget.news),
              ),
            );
            AnalyticsHelper.setLogEvent(Analytics.tappedNewsDetail,
                <String, dynamic>{'title': data.title});
          },
        ),
      ),
    );
  }

  _buildContentList(List<NewsModel> list) {
    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.only(bottom: 10.0),
      itemBuilder: (BuildContext context, int index) {
        return designListNews(list[index]);
      },
    );
  }

  _buildLoading() {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Card(
          margin: EdgeInsets.only(bottom: 10.0),
          elevation: 3.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.maxLength != null ? widget.maxLength : 6,
                  padding: const EdgeInsets.all(10.0),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 80.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Skeleton(
                                width: MediaQuery.of(context).size.width / 4),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            width: MediaQuery.of(context).size.width - 135,
                            child: Column(
                              children: <Widget>[
                                Container(
                                    child: Skeleton(
                                      height: 15.0,
                                      width: MediaQuery.of(context).size.width,
                                    )),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                    child: Skeleton(
                                      height: 15.0,
                                      width: MediaQuery.of(context).size.width,
                                    )),
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Skeleton(
                                            height: 20.0,
                                            width: 20.0,
                                          ),
                                          Skeleton(
                                            height: 15.0,
                                            width: 55.0,
                                            margin: 10.0,
                                          ),
                                        ],
                                      ),
                                      Skeleton(
                                        height: 15.0,
                                        width: 55.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int dex) => Divider()),
              widget.maxLength != null
                  ? Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Skeleton(
                      height: 55.0,
                      width: MediaQuery.of(context).size.width),
                ),
              )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
