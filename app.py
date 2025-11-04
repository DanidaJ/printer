from flask import Flask, request, jsonify
import win32print

app = Flask(__name__)

PRINTER_NAME = "Zebra"  # Change this to your printer name from Control Panel


def send_to_printer(zpl_data):
    """Send ZPL data directly to the Zebra USB printer."""
    try:
        printer = win32print.OpenPrinter(PRINTER_NAME)
        job = win32print.StartDocPrinter(printer, 1, ("ZPL Label", None, "RAW"))
        win32print.StartPagePrinter(printer)
        win32print.WritePrinter(printer, zpl_data.encode("utf-8"))
        win32print.EndPagePrinter(printer)
        win32print.EndDocPrinter(printer)
        win32print.ClosePrinter(printer)
    except Exception as e:
        raise Exception(f"Printer error: {str(e)}")


@app.route("/test", methods=["GET"])
def test():
    """Test endpoint to check if server is running."""
    return jsonify({"status": "success", "message": "Server is running!"})


@app.route("/print/", methods=["POST"])
def print_label():
    try:
        data = request.get_json(force=True)
    except Exception as e:
        return jsonify({"status": "error", "message": f"Invalid JSON: {str(e)}"}), 400
    
    if data is None:
        return jsonify({"status": "error", "message": "No JSON data provided"}), 400

    barcode = data.get("barcode", "")
    order = data.get("order", "")
    size = data.get("size", "")
    piece = data.get("piece", "")

    zpl = fr"""
^XA
^PW400
^LL200

^FO10,20
^A0N,22,22
^FB380,1,0,C,0
^FD{barcode}  {order}  {size}  {piece}\&^FS

^FO80,60
^BY2,2,70
^BCN,70,Y,N,N
^FD{barcode}^FS

^XZ
"""

    try:
        send_to_printer(zpl)
        return jsonify({"status": "success", "message": "Label printed successfully!"})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)
