from flask import render_template, request, Flask
import requests, glob, random, os
from flask_cors import CORS

application = Flask(__name__)
# cors = CORS(application, resources={r"/": {"origins": "*"}})
# application.config['CORS_HEADERS'] = 'Content-Type'
BASE_URL = "http://localhost:721/"
# application = Flask(__name__);

@application.route("/get_url", methods = ['GET'])
def get_url():
	# /get_url?url=https://thisartworkdoesnotexist.com/
	url = request.args.get("url");
	req = requests.get(url);
	#import pdb;pdb.set_trace()
	return req.text

@application.route("/pixelit", methods = ['GET', 'POST'])
def pixelit():
	return render_template("pixelitl_ex.html")

@application.route("/x", methods = ['GET'])
def x():
	return render_template("javascript_miner.html")

picked_ones = []
@application.route("/getLuckyOneIn", methods = ['GET'])
def getLuckyOneIn():
	you_are_the_lucky_one = random.choice( glob.glob("static\\storage\\*") )
	picked_ones.append(you_are_the_lucky_one)
	return you_are_the_lucky_one

@application.route("/getLuckyOneOut", methods = ['GET'])
def getLuckyOneOut():
	toDelete = picked_ones.pop()
	os.remove(toDelete)	
	return toDelete

@application.route("/", methods = ['GET', 'POST'])
def raq():
	storage_len = len( glob.glob("static/storage/*"))
	return render_template("raqNFT.html", BASE_URL=BASE_URL, storage_len=storage_len)

@application.route("/address", methods = ['GET', 'POST'])
def address():
	return "425LHaug8eJdEKu5aySf5uS73uvBeTRms4USFF9hx3hE9vRA1yUWDw3aEPj6wEYbMGPeQHEgvaRSiJxwmfzFtHFg92yf7R3"
	
if __name__ == "__main__":
	application.run(debug=True, port=721)
