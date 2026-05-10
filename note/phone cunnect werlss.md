whoami

১. এনভায়রনমেন্ট ভেরিয়েবল সেট করা (স্থায়ী সমাধান)
সবচেয়ে ভালো বুদ্ধি হলো adb.exe-এর লোকেশনটি আপনার উইন্ডোজের Environment Variables-এ যোগ করে দেওয়া। এটি একবার করলে আপনাকে আর ফাইল পাথ লিখতে হবে না।

কিভাবে করবেন:

উইন্ডোজ সার্চে গিয়ে লিখুন "Edit the system environment variables"।

Environment Variables বাটনে ক্লিক করুন।

System variables এর নিচে Path লেখাটি খুঁজে বের করে Edit এ ক্লিক করুন।

New তে ক্লিক করে এই পাথটি পেস্ট করে দিন: C:\Users\bashi\AppData\Local\Android\Sdk\platform-tools

সব ওকে (OK) করে বের হয়ে আসুন।

adb tcpip 5555
adb connect 192.168.0.102



& "C:\Users\bashi\AppData\Local\Android\Sdk\platform-tools\adb.exe" --version
& "C:\Users\bashi\AppData\Local\Android\Sdk\platform-tools\adb.exe" tcpip 5555
& "C:\Users\bashi\AppData\Local\Android\Sdk\platform-tools\adb.exe" connect 192.168.0.102