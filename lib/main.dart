import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seawatch/screens/MainScreen.dart';
import 'package:seawatch/screens/authentication/LoginScreen.dart';
import 'package:seawatch/screens/authentication/RegistrationScreen.dart';
import 'package:seawatch/screens/settingScreens/SettingsScreen.dart';
import 'package:seawatch/services/AuthServiceGeneral/AuthService.dart';
import 'package:seawatch/services/ManagementTheme/ThemeProvider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  final isAuthenticated = await authService.checkSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: MyApp(isAuthenticated: isAuthenticated),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  const MyApp({Key? key, required this.isAuthenticated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).currentTheme,
      initialRoute: isAuthenticated ? '/main' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/registrazione': (context) => RegistrationScreen(),
        '/main': (context) => const MainScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

/*
NOTA: gestire cambia foto e/o nome e cognome separatemnete se non si riesce a cambiare insieme (chiama due funzioni diverse)
//senza internet disabilitare il pulsanate tanto non serve cambiare il profilo 

senza connesione io devo salavare gli avvistamenti in locale 
Chaimo addImageProfileMob in Single APi passandogli la mail come request 

Per avvsoatemnti singolo AddImage in singke Api (id avvistamento come request)

setUseriNFOMob PER CMABAIARE nome e cognome profilo (EMAIL, nome e cognome)

asterisci = obbligatori 

data prende la propria in automctaica ricoridaris di cmabaiare il fromato 

latituidne e longitudine gps attuale 

nuovo avvsiatmento senza imagine, 
ottemgo l'id che è il timestamp se è andata utto bene 
l'avvistamento può avere più immagini, massimo 5, e vanno caricate ad una ad una 
[si può fare tutti insieme basta che funziona tutto a step]

la password nuova è criptata con la stessa key precdente 
*/

/*
Cosde da fare ancora : sono la gestioen del cambio password, nome e cognome 
gestioen dell'immagine 
gestione oglgine del dispositivo
*/


//aggiungere sfumatura card homepage

//paassword (provathom) ciaothom