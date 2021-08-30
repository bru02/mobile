import 'package:filcnaplo/api/providers/update_provider.dart';
import 'package:filcnaplo_kreta_api/providers/absence_provider.dart';
import 'package:filcnaplo_kreta_api/providers/event_provider.dart';
import 'package:filcnaplo_kreta_api/providers/exam_provider.dart';
import 'package:filcnaplo_kreta_api/providers/grade_provider.dart';
import 'package:filcnaplo_kreta_api/providers/homework_provider.dart';
import 'package:filcnaplo_kreta_api/providers/message_provider.dart';
import 'package:filcnaplo_kreta_api/providers/note_provider.dart';
import 'package:filcnaplo_kreta_api/providers/timetable_provider.dart';
import 'package:filcnaplo/api/providers/user_provider.dart';
import 'package:filcnaplo/api/providers/database_provider.dart';
import 'package:filcnaplo/utils/format.dart';
import 'package:filcnaplo/models/settings.dart';
import 'package:filcnaplo/models/user.dart';
import 'package:filcnaplo/theme.dart';
import 'package:filcnaplo_kreta_api/client/client.dart';
import 'package:filcnaplo_mobile_ui/common/bottom_sheet_menu/bottom_sheet_menu.dart';
import 'package:filcnaplo_mobile_ui/common/bottom_sheet_menu/bottom_sheet_menu_item.dart';
import 'package:filcnaplo_mobile_ui/common/panel/panel.dart';
import 'package:filcnaplo_mobile_ui/common/panel/panel_button.dart';
import 'package:filcnaplo_mobile_ui/common/profile_image/profile_image.dart';
import 'package:filcnaplo_mobile_ui/common/system_chrome.dart';
import 'package:filcnaplo_mobile_ui/screens/news/news_screen.dart';
import 'package:filcnaplo_mobile_ui/screens/settings/accounts/account_tile.dart';
import 'package:filcnaplo_mobile_ui/screens/settings/accounts/account_view.dart';
import 'package:filcnaplo_mobile_ui/screens/settings/settings_helper.dart';
import 'package:filcnaplo_mobile_ui/screens/settings/updates/updates_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as tabs;
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:filcnaplo/utils/color.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int devmodeCountdown = 3;

  late UserProvider user;
  late UpdateProvider updateProvider;
  late SettingsProvider settings;
  late KretaClient kretaClient;
  late String firstName;
  late String themeModeText;
  late String languageText;
  late String startPageTitle;
  List<Widget> accountTiles = [];

  void openDKT(User u) => tabs.launch("https://dkttanulo.e-kreta.hu/sso?accessToken=${kretaClient.accessToken}");

  void _showBottomSheet(User u) {
    showBottomSheetMenu(context, items: [
      // TODO: i18n
      BottomSheetMenuItem(
        onPressed: () => AccountView.show(u, context: context),
        icon: Icon(FeatherIcons.user),
        title: Text("Personal details"),
      ),
      BottomSheetMenuItem(
        onPressed: () => openDKT(u),
        icon: Icon(FeatherIcons.grid, color: AppColors.of(context).teal),
        title: Text("Open DKT"), //TODO
      ),
      // BottomSheetMenuItem(
      //   onPressed: () {},
      //   icon: Icon(FeatherIcons.edit2),
      //   title: Text("Edit nickname"),
      // ),
      // BottomSheetMenuItem(
      //   onPressed: () {},
      //   icon: Icon(FeatherIcons.camera),
      //   title: Text("Edit profile picture"),
      // ),
      // BottomSheetMenuItem(
      //   onPressed: () {},
      //   icon: Icon(FeatherIcons.trash2, color: AppColors.of(context).red),
      //   title: Text("Remove profile picture"),
      // ),
    ]);
  }

  void restore() {
    Provider.of<GradeProvider>(context, listen: false).restore();
    Provider.of<TimetableProvider>(context, listen: false).restore();
    Provider.of<ExamProvider>(context, listen: false).restore();
    Provider.of<HomeworkProvider>(context, listen: false).restore();
    Provider.of<MessageProvider>(context, listen: false).restore();
    Provider.of<NoteProvider>(context, listen: false).restore();
    Provider.of<EventProvider>(context, listen: false).restore();
    Provider.of<AbsenceProvider>(context, listen: false).restore();
    Provider.of<KretaClient>(context, listen: false).refreshLogin();
  }

  void buildAccountTiles() {
    accountTiles = [];
    user.getUsers().forEach((account) {
      if (account.id == user.id) return;

      List<String> _nameParts = account.name.split(" ");
      String _firstName = _nameParts.length > 1 ? _nameParts[1] : _nameParts[0];

      accountTiles.add(AccountTile(
        name: Text(account.name, style: TextStyle(fontWeight: FontWeight.w500)),
        username: Text(account.username),
        profileImage: ProfileImage(name: _firstName, backgroundColor: ColorUtils.stringToColor(account.name)),
        onTap: () {
          user.setUser(account.id);
          restore();
        },
        onTapMenu: () => _showBottomSheet(account),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserProvider>(context);
    settings = Provider.of<SettingsProvider>(context);
    updateProvider = Provider.of<UpdateProvider>(context);
    kretaClient = Provider.of<KretaClient>(context);

    List<String> nameParts = user.name?.split(" ") ?? ["?"];
    firstName = nameParts.length > 1 ? nameParts[1] : nameParts[0];

    startPageTitle = SettingsHelper.pageTitle[settings.startPage] ?? "?";
    themeModeText = {ThemeMode.light: "Light", ThemeMode.dark: "Dark", ThemeMode.system: "System"}[settings.theme] ?? "Unknown";
    languageText = SettingsHelper.langMap[settings.language] ?? "Unknown";

    buildAccountTiles();

    if (settings.developerMode) devmodeCountdown = -1;

    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverAppBar(
            centerTitle: false,
            floating: false,
            snap: false,
            pinned: true,
            expandedHeight: 170.0,
            automaticallyImplyLeading: false,
            shadowColor: AppColors.of(context).shadow.withOpacity(0.5),
            stretch: true,
            leading: IconButton(
              splashRadius: 32.0,
              onPressed: () => _showBottomSheet(user.getUser(user.id ?? "")),
              icon: Icon(FeatherIcons.moreVertical, color: AppColors.of(context).text.withOpacity(0.8)),
            ),
            actions: [
              IconButton(
                splashRadius: 26.0,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(FeatherIcons.x, color: AppColors.of(context).text.withOpacity(0.8)),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: ProfileImage(
                heroTag: "profile",
                radius: 36.0,
                onTap: () => _showBottomSheet(user.getUser(user.id ?? "")),
                name: firstName,
                newContent: updateProvider.available,
                backgroundColor: ColorUtils.stringToColor(user.name ?? "?"),
              ),
              centerTitle: true,
              titlePadding: EdgeInsets.only(bottom: 14.0, left: 52.0, right: 48.0),
              title: Text(
                user.name ?? "?",
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: AppColors.of(context).text),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  child: Panel(
                    child: Column(
                      children: [
                        // Account list
                        ...accountTiles,

                        // Account settings
                        PanelButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed("login_back").then((value) {
                              setSystemChrome(context);
                            });
                          },
                          title: Text("Add User"), // TODO: i18n
                          leading: Icon(FeatherIcons.userPlus),
                        ),
                        PanelButton(
                          onPressed: () async {
                            String? userId = user.id;
                            if (userId == null) return;

                            // Delete User
                            user.removeUser(userId);
                            await Provider.of<DatabaseProvider>(context, listen: false).store.removeUser(userId);

                            // If no other Users left, go back to LoginScreen
                            if (user.getUsers().length > 0) {
                              user.setUser(user.getUsers().first.id);
                              restore();
                            } else {
                              Navigator.of(context).pushNamedAndRemoveUntil("login", (_) => false);
                            }
                          },
                          title: Text("Log Out"), // TODO: i18n
                          leading: Icon(FeatherIcons.logOut, color: AppColors.of(context).red),
                        ),
                      ],
                    ),
                  ),
                ),

                // Updates
                if (updateProvider.available)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    child: Panel(
                      child: PanelButton(
                        onPressed: () => openUpdates(context),
                        title: Text("Update available"),
                        leading: Icon(FeatherIcons.download),
                        trailing: Text(
                          updateProvider.releases.first.tag,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),

                // General Settings
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  child: Panel(
                    title: Text("General"),
                    child: Column(
                      children: [
                        PanelButton(
                          onPressed: () {
                            SettingsHelper.language(context);
                            setState(() {});
                          },
                          title: Text("Language"),
                          leading: Icon(FeatherIcons.globe),
                          trailing: Text(languageText),
                        ),
                        PanelButton(
                          onPressed: () {
                            SettingsHelper.startPage(context);
                            setState(() {});
                          },
                          title: Text("Startpage"),
                          leading: Icon(FeatherIcons.play),
                          trailing: Text(startPageTitle.capital()),
                        ),
                        PanelButton(
                          onPressed: () {
                            SettingsHelper.rounding(context);
                            setState(() {});
                          },
                          title: Text("Rounding"),
                          leading: Icon(FeatherIcons.gitCommit),
                          trailing: Text((settings.rounding / 10).toStringAsFixed(1)),
                        ),
                      ],
                    ),
                  ),
                ),

                // Theme Settings
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  child: Panel(
                    title: Text("Appearance"),
                    child: Column(
                      children: [
                        PanelButton(
                          onPressed: () {
                            SettingsHelper.theme(context);
                            setState(() {});
                          },
                          title: Text("Theme"),
                          leading: Icon(FeatherIcons.sun),
                          trailing: Text(themeModeText),
                        ),
                        PanelButton(
                          onPressed: () {
                            SettingsHelper.accentColor(context);
                            setState(() {});
                          },
                          title: Text("Accent Color"),
                          leading: Icon(FeatherIcons.droplet),
                          trailing: Container(
                            width: 12.0,
                            height: 12.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        PanelButton(
                          onPressed: () {
                            SettingsHelper.gradeColors(context);
                            setState(() {});
                          },
                          title: Text("Grade Colors"),
                          leading: Icon(FeatherIcons.star),
                        ),
                      ],
                    ),
                  ),
                ),

                // Notifications
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  child: Panel(
                    title: Text("Notifications"),
                    child: SwitchListTile(
                      title: Text("News", style: TextStyle(fontWeight: FontWeight.w500)),
                      onChanged: (v) => settings.update(context, newsEnabled: v),
                      value: settings.newsEnabled,
                      activeColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),

                // About
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  child: Panel(
                    title: Text("About"),
                    child: Column(children: [
                      PanelButton(
                        leading: Icon(FeatherIcons.atSign),
                        title: Text("Discord"),
                        onPressed: () => launch("https://filcnaplo.hu/discord"),
                      ),
                      PanelButton(
                        leading: Icon(FeatherIcons.globe),
                        title: Text("www.filcnaplo.hu"),
                        onPressed: () => launch("https://filcnaplo.hu"),
                      ),
                      PanelButton(
                        leading: Icon(FeatherIcons.github),
                        title: Text("Github"),
                        onPressed: () => launch("https://github.com/filc"),
                      ),
                      PanelButton(
                        leading: Icon(FeatherIcons.mail),
                        title: Text("Hírek"),
                        onPressed: () => openNews(context), // TODO
                      ),
                      PanelButton(
                        leading: Icon(FeatherIcons.dollarSign),
                        title: Text("Támogatók"),
                        // onPressed: () => openSupporters(context), // TODO
                      ),
                      PanelButton(
                        leading: Icon(FeatherIcons.lock),
                        title: Text("Adatvédelmi irányelvek"),
                        // onPressed: () => openPrivacy(context), // TODO
                      ),
                      PanelButton(
                        leading: Icon(FeatherIcons.award),
                        title: Text("Licenszek"),
                        onPressed: () => showLicensePage(context: context),
                      ),
                    ]),
                  ),
                ),
                if (settings.developerMode)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    child: Panel(
                      title: Text("Developer Settings"),
                      child: SwitchListTile(
                        title: Text("Developer Mode", style: TextStyle(fontWeight: FontWeight.w500)),
                        onChanged: (v) => settings.update(context, developerMode: false),
                        value: settings.developerMode,
                        activeColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                Center(
                  child: GestureDetector(
                    child: Panel(title: Text("v" + (settings.packageInfo?.version ?? ""))),
                    onTap: () {
                      if (devmodeCountdown > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(milliseconds: 200),
                          content: Text("You are $devmodeCountdown taps away from Developer Mode."),
                        ));

                        setState(() => devmodeCountdown--);
                      } else if (devmodeCountdown == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Developer Mode successfully activated."),
                        ));

                        settings.update(context, developerMode: true);

                        setState(() => devmodeCountdown--);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void openNews(BuildContext context) => Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(builder: (context) => NewsScreen()));
  void openUpdates(BuildContext context) => UpdateView.show(updateProvider.releases.first, context: context);
}