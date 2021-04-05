apt update
apt install -y apache2
cat <<EOF > /var/www/html/index.html
<html>
    <body>
        <h2>Hello and bye</h2>
        <h3>So long, and thanks for all the fish!</h3>
    </body>
</html>
EOF