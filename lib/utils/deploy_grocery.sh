
cd ~/Documents/repositories/grocery_list_app/
flutter build web

rm -R ~/Documents/repositories/grocery_list_web/*
cp -R ~/Documents/repositories/grocery_list_app/build/web/* ~/Documents/repositories/grocery_list_web

cd ~/Documents/repositories/grocery_list_web
sed '17d' index.html > temp.html
cat temp.html > index.html
rm temp.html

git add -A
git commit -m "Deploying web app"
git push --force