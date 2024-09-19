import lyricsgenius
import requests
from tkinter import filedialog, Tk, Label, Button, Entry, StringVar, scrolledtext
from tkinter import ttk
from moviepy.editor import VideoClip, AudioFileClip, TextClip, concatenate_videoclips, CompositeVideoClip, ImageClip
from pydub import AudioSegment
from PIL import Image, ImageTk
import tkinter as tk

# Genius APIトークン
GENIUS_API_KEY = "your token"

# Genius APIのセットアップ
genius = lyricsgenius.Genius(GENIUS_API_KEY)

# ナイトコア効果を適用する関数
# 歌詞をGeniusから取得する関数
def fetch_lyrics(artist_name, song_title):
    try:
        artist = genius.search_artist(artist_name, max_songs=0)  # アーティストを検索
        song = genius.search_song(song_title, artist.name)  # 曲を検索
        if song:
            return song.lyrics
        else:
            return "Lyrics not found."
    except Exception as e:
        return f"Error fetching lyrics: {e}"

# 歌詞取得ボタンの処理
def get_lyrics():
    artist_name = artist_entry.get()
    song_title = song_entry.get()

    if artist_name and song_title:
        lyrics = fetch_lyrics(artist_name, song_title)
        lyrics_display.delete(1.0, tk.END)
        lyrics_display.insert(tk.END, lyrics)
    else:
        lyrics_display.insert(tk.END, "Please enter both artist name and song title.")

# MP3ファイルと背景画像をアップロードする処理

   
    # 歌詞の取得
    lyrics = lyrics_display.get(1.0, tk.END)

    # ビデオの生成
    
# GUIの設定
root = Tk()
root.title("Nightcore Video Generator")

# アーティスト名入力フィールド
Label(root, text="Enter Artist Name:").pack(pady=5)
artist_entry = Entry(root, width=50)
artist_entry.pack(pady=5)

# 曲名入力フィールド
Label(root, text="Enter Song Title:").pack(pady=5)
song_entry = Entry(root, width=50)
song_entry.pack(pady=5)

# 歌詞取得ボタン
lyrics_button = Button(root, text="Get Lyrics", command=get_lyrics)
lyrics_button.pack(pady=5)

# 歌詞を表示するスクロールテキストウィジェット
Label(root, text="Lyrics:").pack(pady=5)
lyrics_display = scrolledtext.ScrolledText(root, height=15, width=80, wrap='word')
lyrics_display.pack(pady=5)

# ステータスラベル
status_label = Label(root, text="")
status_label.pack(pady=5)



# アプリケーションのメインループ
root.mainloop()
