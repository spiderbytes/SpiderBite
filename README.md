# SpiderBite

## Was ist das hier?

SpiderBite ist ein Präprozessor für SpiderBasic, der es ermöglicht, in einem Code Bereiche zu markieren, die auf dem WebServer ausgeführt werden (der sogenannte ServerCode (PB2Web-User werden es kennen :wink:)). 

Wie bekannt ist, kann und darf der von SpiderBasic generierte Code nicht direkt auf die Hardware des WebServers zugreifen. Somit ist es nicht möglich, direkte Datenbankabfragen, Filesystemzugriffe oder sonstiges aus SpiderBasic auszuführen. Die bisherige Vorgehensweise ist es, eine serverseitige Komponente zu programmieren (sei es als CGI oder PHP- (ASP-, Python-, ...) Script) und diese Komponente dann in SpiderBasic mittels HttpRequest() aufzurufen. Das funktioniert eigentlich ganz gut, ist aber meines Erachtens nicht besonders komfortabel. Aus diesem Grund habe ich mich entschlossen, SpiderBite zu entwickeln.

### Ein simples Beispiel

```
EnablePbCgi

  ; der Code in diesem Block wird auf dem Server ausgeführt

  Procedure.s myPbCgiProcedure()
    ProcedureReturn "Hello from myPbCgiProcedure"
  EndProcedure

DisablePbCgi

Debug myPbCgiProcedure()
```

Der Code, der oben in dem `EnablePbCgi/DisablePbCgi` - Block notiert ist, wird vor dem eigentlichen Konvertierungsvorgang durch SpiderBite extrahiert und in eine eigene PureBasic-Executable kompiliert (eine sogenannte CGI-EXE), die dann auf dem Server ausgeführt wird. Hierbei steht im ServerCode-Block der gesamte PureBasic-Befehlsvorrat zur Verfügung.

Neben der Möglichkeit, PureBasic-CGI zu erstellen stehen auch Blockbereiche für PHP, ASP und ASPX zur Verfügung. Ein Beispiel für PHP:

```
EnablePHP
  
  Procedure myPhpProcedure()
    ! return "Hello from myPhpProcedure";
  EndProcedure
  
DisablePHP

Debug myPhpProcedure()
```
Die PHP-Befehle werden hier durch ein führendes Ausrufezeichen markiert.

Es ist möglich unterschiedliche Blockbereiche in einem Source zu nutzen (hier: PbCgi und PHP):

```
EnablePbCgi
  Procedure.s myPbCgiProcedure()
    ProcedureReturn "Hello from myPbCgiProcedure"
  EndProcedure
DisablePbCgi

EnablePHP
  Procedure.s myPhpProcedure()
    ! return "Hello from myPhpProcedure";
  EndProcedure
DisablePHP

Debug myPbCgiProcedure()
Debug myPhpProcedure()
```

Blockbereiche für NodeJs und Python sind in Planung.

## Systemvoraussetzungen

* SpiderBasic

* PureBasic (um die Sourcen zu kompilieren und für den Fall, dass PB Cgi erstellt werden sollen)

* Einen beliebigen Webserver (Apache, IIS, nginx, ...)

## Installation

GitHub-Kenner klonen sich dieses Projekt auf Ihren Datenträger an einen Ort ihrer Wahl. Menschen, die sich nicht mit GitHub auskennen, haben sie Möglichkeit, sich die Sourcen als ZIP herunterzuladen:

![](http://i.imgur.com/2SxgUyA.png)

Danach müssen die PB-Sourcen (`SpiderBite.pb`, `SpiderBiteAfterCreateApp.pb` und `SpiderBiteConfig.pb`) mit PureBasic kompiliert werden und als Tools in SpiderBasic eingerichtet werden.

### SpiderBite als SpiderBasic-Tools einrichten

Nachdem die Sourcen kompiliert wurden, wird SpiderBite als SpiderBasic-Tools installiert. Es ist darauf zu achten, dass als Übergabeparameter "`%COMPILEFILE`" angegeben wird. Ebenso sollten die beiden Checkboxen "`Wait until tool quits`" und "`Hide tool from the Main menu`" aktiviert sein.

#### Before Compile / Run

Dieses Tool tritt in Aktion, wenn in SpiderBasic `Compile/Run` aufgerufen wird. Also jedes Mal, wenn `<F5>` gedrückt wird.

![](http://i.imgur.com/sTWcQmD.png)

#### Before Create App

Dieses Tool tritt in Aktion, wenn in SpiderBasic `Create App...` aufgerufen wird, um eine App zu erstellen.

![](http://i.imgur.com/xVk67QQ.png)

#### After Create App

**Wichtig!** Aufgrund eines Fehlers in SpiderBasic wird nicht das erzeugte Temp-File als Grundlage für die zu erstellende App verwendet, sondern der Original-Source. Bis dieser Fehler behoben wird, muss hier ein wenig getrickst werden und ein separates Programm (`SpiderBiteAfterCreateApp.exe`) als Tool eingerichtet werden.

![](http://i.imgur.com/oXpURyf.png)

##

Und so sieht es dann aus, wenn alle Tools richtig eingetragen sind:

![](http://i.imgur.com/GUKiyFb.png)

## SpiderBiteConfig

Mit SpiderBiteConfig können Profile angelegt werden, die dann im SpiderBasic-Code angegeben werden:

![](http://i.imgur.com/eXvhJLn.png)

![](http://i.imgur.com/zg9aw5y.png)

Soll beispielsweise ein PureBasic-CGI erstellt werden, so muss in SpiderBiteConfig festgelegt werden, wo sich der PureBasic-Compiler befindet. Des weiteren muss angegeben werden, wo das CGI gespeichert werden soll (`PbCgiServerFilename`) und wie es vom Browser aus aufgerufen werden kann (`PbCgiServerAddress`). Schlussendlich kann ein Template ausgewählt werden, welches als Grundlage für das zu erstellende CGI verwendet wird. Wird kein Template angegeben, so wird ein Standard-Template verwendet.

Des weiteren muss die Datei `SpiderBite.sbi` eingebunden werden. Sie befindet sich im `include` - Ordner.

```
XIncludeFile "[PathTo]/SpiderBite.sbi"

#SpiderBite_Profile = "default" ; hiermit wird das Profil angegeben

EnablePbCgi
  Procedure.s myPbCgiProcedure()
    ProcedureReturn "Hello from myPbCgiProcedure"
  EndProcedure
DisablePbCgi

Debug myPbCgiProcedure()
```

Alternativ kann die Datei `SpiderBite.res` in den Residents-Ordner von SpiderBasic kopiert werden.

SpiderBiteConfig kann optional ebenfalls als Tool installiert werden, um die Konfigurationen komfortabel aus SpiderBasic heraus zu verwalten.

## Synchrone Kommunikation vs Asynchrone Kommunikation

SpiderBite verwendet für die Kommunikation zwischen Client (Browser) und Server Ajax-Aufrufe. Diese können synchron und asynchron erfolgen.

Der Vorteil eines synchronen Aufrufes ist, dass der Rückgabewert in der gleichen Zeile zur Verfügung steht, in der die Funktion aufgerufen wird.

Synchroner Aufruf:
```
Enable*
  Procedure.s myProcedure()
    ProcedureReturn "Hello World"
  EndProcedure
Disable*

Debug myProcedure() ; hier kann die Rückgabe ausgewertet werden.
```

Der Nachteil eines synchronen Aufrufes besteht darin, dass der Code so lange in der Zeile des Aufrufes wartet, bis der Server den Rückgabewert liefert.

Das kann dazu führen, dass der Browser nicht mehr reagiert, wenn der Server zu lange benötigt, um den Rückgabewert zu liefern (beispielsweise bei einer schlechten Verbindung zwischen Client und Server oder bei langen Laufzeiten von Prozeduren).

Aus diesem Grund wird empfohlen, asynchrone Aufrufe zu verwenden. Das hat zwar mehr Programmieraufwand zur Folge, resultiert aber in einem jederzeit reagierenden Browser.

Ein asynchroner Aufruf erfolgt, wenn sich im Client-Code eine Prozedur gleichen Namens mit angehängtem ```Callback``` befindet:

Server-Code: ```myProcedure()```

Client-Code: ```myProcedureCallback()```

Ein asynchroner Aufruf sähe dementsprechend so aus:
```
Procedure myProcedureCallback(Success, Result.s)
  Debug Result ; hier wird der Rückgabewert des Aufrufes
               ; myProcedure() geliefert.
EndProcedure

Enable*
  Procedure.s myProcedure()
    ProcedureReturn "Hello World"
  EndProcedure
Disable*

myProcedure() ; hier wird kein Rückgabewert geliefert!

If 1=2
  myProcedureCallback(0, "") ; ein 'Blind'-Aufruf
EndIf
```

**Wichtig:** SpiderBasic optimiert den Code. Ungenutzte Prozeduren werden nicht mitkompiliert. Da SpiderBite den im ServerCode-Block befindlichen Aufruf von `myProcedureCallback` durch einen Ajax-Aufruf ersetzt, 'denkt' SpiderBasic, dass die Prozedur nicht aufgerufen wird. Demzufolge wird sie von SpiderBasic entfernt. Aus diesem Grund müssen wir den Aufruf an anderer Stelle simulieren:
```
If 1=2
  myProcedureCallback(0, "") ; ein 'Blind'-Aufruf
EndIf
```

## Templates

{ToDo}

## ToDo

* Momentan sind nur einfache Übergabeparameter (Zeichenketten und Zahlen) erlaubt.

## Fragen? Anregungen? Fehlermeldungen?

[SpiderBasic-Forum (englisch)](http://forums.spiderbasic.com/index.php)

[SpiderBasic-Forum (deutsch)](http://www.purebasic.fr/german/viewforum.php?f=33)

## Lizenz

[MIT](https://github.com/spiderbytes/SpiderBite/blob/master/LICENSE)
