inotify - monitoring file system events 
---
Inotify can be used to monitor individual files, or to monitor directories. When a directory is monitored, inotify will return events for the directory itself, and for files inside the directory.

# /proc interfaces

The following interfaces can be used to limit the amount of kernel memory consumed by inotify:
* /proc/sys/fs/inotify/max_queued_events
  
  The value in this file is used when an application calls inotify_init(2) to set an upper limit on the number of events that can be queued to the corresponding inotify instance. Events in excess of this limit are dropped, but an IN_Q_OVERFLOW event is always generated. 
  
* /proc/sys/fs/inotify/max_user_instances

  This specifies an upper limit on the number of inotify instances that can be created per real user ID. 
  
* /proc/sys/fs/inotify/max_user_watches

  This specifies an upper limit on the number of watches that can be created per real user ID. 


[too many open files](https://blog.csdn.net/weiguang1017/article/details/54381439)
