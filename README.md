# SpiderBite

## Was ist das hier?

SpiderBite ist ein Präprozessor für SpiderBasic, der es ermöglicht, in einem Code Bereiche zu markieren, die auf dem WebServer ausgeführt werden (der sogenannte ServerCode (PB2Web-User werden es kennen :wink:)). 

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

Der Code, der oben in dem EnablePbCgi/DisablePbCgi - Block notiert ist, wird vor dem eigentlichen Konvertierungsvorgang durch SpiderBite extrahiert und in eine eigene PureBasic-Executable kompiliert (eine sogenannte CGI-EXE), die dann auf dem Server ausgeführt wird. Hierbei steht im ServerCode-Block der gesamte PureBasic-Befehlsvorrat zur Verfügung.

Neben der Möglichkeit, PureBasic-CGI zu erstellen stehen auch Blockbereiche für PHP, ASP und ASPX zur Verfügung. Ein Beispiel für PHP:

```
EnablePHP
  
  Procedure myPhpProcedure()
    ! return "Hello from myPhpProcedure";
  EndProcedure
  
DisablePHP

Debug myPhpProcedure()
```

Blockbereiche für NodeJs und Python sind in Planung.

## Installation

GitHub-Kenner klonen sich diese Projekt auf Ihren Datenträger an einen Ort ihrer Wahl. Menschen, die sich nicht mit GitHub auskennen, haben sie Möglichkeit, sich die Sourcen als ZIP herunterzuladen:

![](http://i.imgur.com/2SxgUyA.png)

Danach müssen die PB-Sourcen (SpiderBite.pb und SpiderBiteConfig.pb) mit PureBasic kompiliert werden.

Sobald das geschehen ist, wird SpiderBite als SpiderBasic-Tool installiert:

![](http://i.imgur.com/shOpccz.png)

Es ist darauf zu achten, dass als Übergabeparameter "%COMPILEFILE" angegeben wird.
Ebenso sollten die beiden Checkboxen "Wait until tool quits" und "Hide tool from the Main menu" aktiviert sein.

![](http://i.imgur.com/tHOv1M2.png)

SpiderBiteConfig kann optional ebenfalls als Tool installiert werden, um die Konfigurationen komfortabel aus SpiderBasic heraus zu verwalten.

## SpiderBiteConfig

Mit SpiderBiteConfig können Profile angelegt werden, die dann im SpiderBasic-Code angegeben werden:

![](http://i.imgur.com/eXvhJLn.png)

![](http://i.imgur.com/zg9aw5y.png)

Soll beispielsweise ein PureBasic-CGI erstellt werden, so muss in SpiderBiteConfig festgelegt werden, wo sich der PureBasic-Compiler befindet. Des weiteren muss angegeben werden, wo das CGI gespeichert werden soll (PbCgiServerFilename) und wie es vom Browser aus aufgerufen werden kann (PbCgiServerAddress). Schlussendlich kann ein Template ausgewählt werden, welches als Grundlage für das zu erstellende CGI verwendet wird. Wird kein Template angegeben, so wird ein Standard-Template verwendet.

```
#SpiderBite_Profile = "default"

EnablePbCgi

  ; der Code in diesem Block wird auf dem Server ausgeführt

  Procedure.s myPbCgiProcedure()
    ProcedureReturn "Hello from myPbCgiProcedure"
  EndProcedure

DisablePbCgi

Debug myPbCgiProcedure()
```

## Synchrone Kommunikation vs Asynchrone Kommunikation

{ToDo}

## Templates

{ToDo}

# Lizenz

MIT-Lizenz

Copyright (c) 2017 Peter Tübben

Hiermit wird unentgeltlich jeder Person, die eine Kopie der Software und der zugehörigen Dokumentationen (die "Software") erhält, die Erlaubnis erteilt, sie uneingeschränkt zu nutzen, inklusive und ohne Ausnahme mit dem Recht, sie zu verwenden, zu kopieren, zu verändern, zusammenzufügen, zu veröffentlichen, zu verbreiten, zu unterlizenzieren und/oder zu verkaufen, und Personen, denen diese Software überlassen wird, diese Rechte zu verschaffen, unter den folgenden Bedingungen:

Der obige Urheberrechtsvermerk und dieser Erlaubnisvermerk sind in allen Kopien oder Teilkopien der Software beizulegen.

DIE SOFTWARE WIRD OHNE JEDE AUSDRÜCKLICHE ODER IMPLIZIERTE GARANTIE BEREITGESTELLT, EINSCHLIEẞLICH DER GARANTIE ZUR BENUTZUNG FÜR DEN VORGESEHENEN ODER EINEM BESTIMMTEN ZWECK SOWIE JEGLICHER RECHTSVERLETZUNG, JEDOCH NICHT DARAUF BESCHRÄNKT. IN KEINEM FALL SIND DIE AUTOREN ODER COPYRIGHTINHABER FÜR JEGLICHEN SCHADEN ODER SONSTIGE ANSPRÜCHE HAFTBAR ZU MACHEN, OB INFOLGE DER ERFÜLLUNG EINES VERTRAGES, EINES DELIKTES ODER ANDERS IM ZUSAMMENHANG MIT DER SOFTWARE ODER SONSTIGER VERWENDUNG DER SOFTWARE ENTSTANDEN.
