remote-staging:
	git remote remove heroku
	 heroku git:remote -a rewordgame-staging

remote-prod:
	git remote remove heroku
	heroku git:remote -a rewordgame
