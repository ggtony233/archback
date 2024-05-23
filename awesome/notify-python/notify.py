#!/usr/bin/python3

import os
import gi
import pyinotify
import threading
from systemd import journal
import websocket
import json

gi.require_version('Notify', '0.7')
from gi.repository import Notify

# 初始化通知
Notify.init("System Event Notifier")

def send_notification(summary, body, icon="dialog-information"):
    notification = Notify.Notification.new(summary, body, icon)
    notification.show()

class EventHandler(pyinotify.ProcessEvent):
    def process_IN_CREATE(self, event):
        send_notification("File Created", f"New file: {event.pathname}")

    def process_IN_DELETE(self, event):
        send_notification("File Deleted", f"Deleted file: {event.pathname}")

    def process_IN_MODIFY(self, event):
        send_notification("File Modified", f"Modified file: {event.pathname}")

def monitor_filesystem(path_to_watch):
    wm = pyinotify.WatchManager()
    event_handler = EventHandler()
    mask = pyinotify.IN_CREATE | pyinotify.IN_DELETE | pyinotify.IN_MODIFY
    notifier = pyinotify.Notifier(wm, event_handler)
    wm.add_watch(path_to_watch, mask, rec=True)
    notifier.loop()

def monitor_system_log():
    j = journal.Reader()
    j.log_level(journal.LOG_INFO)
    j.add_match(_SYSTEMD_UNIT="kernel")
    j.seek_tail()
    j.get_previous()

    while True:
        if j.process() != journal.APPEND:
            continue
        for entry in j:
            send_notification("System Log", entry['MESSAGE'])

def on_message(ws, message):
    data = json.loads(message)
    send_notification("Gotify Message", data['title']+"\n"+data['message'], "dialog-information")

def on_error(ws, error):
    send_notification("Gotify Error", str(error), "dialog-error")

def on_close(ws, close_status_code, close_msg):
    send_notification("Gotify Connection Closed", str(close_msg), "dialog-error")

def on_open(ws):
    send_notification("Gotify Connection Opened", "Connected to Gotify server", "dialog-information")

def monitor_gotify(gotify_url, token):
    ws = websocket.WebSocketApp(
        f"{gotify_url}/stream?token={token}",
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close
    )
    ws.run_forever()

if __name__ == "__main__":
    
    path_to_watch = os.path.expanduser("~")
    # 读取 JSON 文件以获取 Gotify 地址和 token
    with open(path_to_watch + "/archconfbackup/awesome/notify-python/gotify_config.json", "r") as config_file:
        config_data = json.load(config_file)
        gotify_url = config_data["gotify_address"]
        gotify_token = config_data["gotify_token"]
    # 定义需要监控的文件系统目录
    # 启动文件系统监控线程
#    fs_thread = threading.Thread(target=monitor_filesystem, args=(path_to_watch,))
#    fs_thread.start()

    # 启动系统日志监控线程
    log_thread = threading.Thread(target=monitor_system_log)
    log_thread.start()

    gotify_thread = threading.Thread(target=monitor_gotify, args=(gotify_url, gotify_token))
    gotify_thread.start()
    # 等待线程完成
    fs_thread.join()
    log_thread.join()
