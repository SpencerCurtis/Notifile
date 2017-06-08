# Notifile

Notifile is a macOS application meant to alert you when the contents of a directory have changed. I built this because my NAS will download files on a semi-regular schedule, but I wanted to be notified when the files were added. An iOS app that uses CloudKit to receive notifications of file updates on my iOS devices is being written as well. 

Notifile uses `DispatchSource`s to observe the events on a specific folder. 

At this time, if you wish to observe changes to a directory on a network drive such as a NAS, you must keep a Finder window open that will keep the network drive mounted.

This application is very much in its early stages the UI is very buggy.
