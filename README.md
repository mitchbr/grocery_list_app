# Grocery List

Welcome to the Grocery List App! I use this app for managing all of my grocery trips, and store recipes to minimize the effort it takes to make lists for grocery trips. This app is run on Flutter, which I am hosting as a PWA on GitHub. It is also hooked up to a Google Firestore backend, with plans to migrate to a self-hosted raspberry pi API. The app contains three main pages which I will run through.

The app is available to play with here, feel free to sign in with `mitchbr` (My test user) and play around however you want!
https://mitchbr.github.io/grocery_list_web/#/

## Checklist Page

<img width="502" alt="Screenshot 2024-05-16 at 1 10 08 PM" src="https://github.com/mitchbr/grocery_list_app/assets/40349575/5766d4c8-d938-4fc3-b6cc-4b8ba06ac5c7">

The main page of the app. Items can be added, checked/unchecked, reordered, and deleted (by swiping to the side). Items from recipes are added here as well, which I will run through below.

## Recipes page

<img width="502" alt="Screenshot 2024-05-16 at 1 10 25 PM" src="https://github.com/mitchbr/grocery_list_app/assets/40349575/04c70bb6-b583-4d46-bc02-fed784aa157e">


I would call this page the "meat" of the app. Here, you can view your list of your personal recipes, as well as recipes you've saved from other users. Recipes can be pinned to the top of the list, and there are filtering, sorting, searching, importing, and creating options as well
### Filtering and sorting
<img width="502" alt="Screenshot 2024-05-16 at 1 11 49 PM" src="https://github.com/mitchbr/grocery_list_app/assets/40349575/1e0f1eb6-97f7-44da-9c9e-d6d0767fa52d">

<img width="502" alt="Screenshot 2024-05-16 at 1 12 04 PM" src="https://github.com/mitchbr/grocery_list_app/assets/40349575/5e895351-3bbb-4ac8-aeb8-f6aa2f519c28">

### Recipe Drawer

<img width="502" alt="Screenshot 2024-05-16 at 1 13 48 PM" src="https://github.com/mitchbr/grocery_list_app/assets/40349575/ffbf20f8-2314-4516-b990-2589c42662c6">

<img width="501" alt="Screenshot 2024-05-16 at 1 14 16 PM" src="https://github.com/mitchbr/grocery_list_app/assets/40349575/1fce8969-ae7e-4b62-970c-e0c876d9f94f">

Tapping on a recipe in the previous list will open the recipe drawer, where you can view ingredients, instructions, and other metadata on the recipe. There are also options to share, edit, and delete the recipe. Checking items and hitting `Save to Grocery List` will add the checked items to the checklist page shown above.

## Authors page

<img width="503" alt="Screenshot 2024-05-16 at 1 16 26 PM" src="https://github.com/mitchbr/grocery_list_app/assets/40349575/dfeabb0e-c4c6-4a1a-beef-eefb2e5f47b3">

Here, users can view other users that they follow. Tapping a users name will open their list of recipes, similar to shown above. Then, users can save other's recipes to their own recipes page.
