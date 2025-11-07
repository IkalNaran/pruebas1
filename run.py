from app import create_app, socketio
import os

app = create_app()

if __name__ == "__main__":
    # Run using Socket.IO so background tasks and websocket transport work
    port = int(os.environ.get('PORT', '5001'))
    socketio.run(app, debug=True, port=port)
