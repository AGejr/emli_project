from flask import Flask, send_from_directory, render_template, abort
import os

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/photos')
def folder_a():
    # Show picture and metadata files
    files = list_files('/home/emli/Git/emli_project/path/to/photo/folder')
    return render_template('directory.html', files=files, folder='photos')

@app.route('/logs')
def folder_b():
    # Show log files
    files = list_files('/home/emli/Git/emli_project/path/to/log/folder')
    return render_template('directory.html', files=files, folder='logs')

@app.route('/photos/<path:filename>')
def folder_a_files(filename):
    # Make files in folder downloadable
    directory = '/home/emli/Git/emli_project/path/to/photo/folder'
    try:
        return send_from_directory(directory, filename, as_attachment=True)
    except FileNotFoundError:
        abort(404)

@app.route('/logs/<path:filename>')
def folder_b_files(filename):
    # Make logs downloadable
    directory = '/home/emli/Git/emli_project/path/to/log/folder'
    try:
        return send_from_directory(directory, filename, as_attachment=True)
    except FileNotFoundError:
        abort(404)

def list_files(directory):
    # List files in folder
    try:
        return [f for f in os.listdir(directory) if os.path.isfile(os.path.join(directory, f))]
    except OSError:
        return []

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
