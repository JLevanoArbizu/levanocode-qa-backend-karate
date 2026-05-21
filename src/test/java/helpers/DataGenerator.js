function fn() {

    var fakerInstance = null;

    try {
        var FakerClass = Java.type('com.github.javafaker.Faker');
        fakerInstance = new FakerClass();
    } catch (e) {
        FakerClass = null;
    }

    return {
        getRandomUser: function () {
            if (fakerInstance) {

                var name = fakerInstance.name().fullName();
                var safeEmail = fakerInstance.internet().safeEmailAddress();
                var password = fakerInstance.internet().password(10, 20);

                return {
                    nome: name,
                    email: safeEmail,
                    password: password,
                    administrador: "true"
                };
            }

            var entropy = new Date().getTime() + "_" + Math.floor(Math.random() * 100000);
            return {
                nome: "TestUser " + entropy,
                email: "user." + entropy + "@serverest.com.br",
                password: "Pass" + Math.floor(Math.random() * 10000),
                administrador: "true"
            }
        }
    };
}
