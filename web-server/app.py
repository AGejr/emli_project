from flask import Flask, send_from_directory, render_template, abort
import os

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html', folders=['logs', 'photos'])

@app.route('/photos')
def show_photos():
    # List folders within the photos folder
    photos_path = '/home/emli/Git/emli_project/photos'
    try:
        directories = [d for d in os.listdir(photos_path) if os.path.isdir(os.path.join(photos_path, d))]
        return render_template('photos.html', directories=directories, base_path='photos')
    except FileNotFoundError:
        abort(404)

@app.route('/photos/<path:subpath>')
def show_photo_contents(subpath):
    # List files within each photos folder
    full_path = os.path.join('/home/emli/Git/emli_project/photos', subpath)
    if os.path.isdir(full_path):
        files = [f for f in os.listdir(full_path) if os.path.isfile(os.path.join(full_path, f))]
        return render_template('directory.html', files=files, folder=subpath, base_path='photos')
    else:
        return send_from_directory(os.path.dirname(full_path), os.path.basename(full_path), as_attachment=True)

@app.route('/logs')
def show_logs():
    # Path to the log file
    log_file_path = '/home/emli/Git/emli_project/path/logs/logfile.log'
    try:
        with open(log_file_path, 'r') as file:
            log_contents = file.read()
        return render_template('logs.html', log_contents=log_contents)
    except FileNotFoundError:
        abort(404)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
