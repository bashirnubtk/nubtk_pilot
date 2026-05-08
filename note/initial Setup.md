# পরিচয় সেট করা (একবার করলেই হবে)
git config --global user.email "bashircse.nubtk@gmail.com"
git config --global user.name "bashirnubtk"

# প্রজেক্ট ক্লোন করা
cd E:\Projects
git clone https://github.com/bashirnubtk/nubtk_pilot.git

# প্রজেক্ট ফোল্ডারে ঢোকা এবং ডেভ ব্রাঞ্চে যাওয়া
cd nubtk_pilot
git checkout dev

# প্যাকেজ ইন্সটল করা
flutter pub get


# অন্য ডিভাইসের করা কাজ এই ডিভাইসে আনা
git pull origin dev