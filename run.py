from app import create_app, socketio

app = create_app()

if __name__ == "__main__":
    # Run using Socket.IO so background tasks and websocket transport work
    socketio.run(app, debug=True)
