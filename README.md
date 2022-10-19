# apivideo_issue_17

This repository was created to replicate issue [#17](https://github.com/apivideo/api.video-flutter-live-stream/issues/17) from Flutter package [apivideo_live_stream](https://pub.dev/packages/apivideo_live_stream).

Steps to replicate:
1) Deploy to iOS device
2) While rotating the device keep tapping the button to change orientation
3) Eventually stream distortion should happen

I found that rotating slowly would make the issue manifest sooner though it's completely random, sometimes it would happen quite often and sometimes almost not at all.

Screenshot from this sample app showing the issue:
![Screenshot](/screenshot.jpeg)
