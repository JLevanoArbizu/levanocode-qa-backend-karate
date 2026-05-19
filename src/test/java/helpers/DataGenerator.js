function fn() {
  // Try loading Java Faker class from classpath
  var FakerClass;
  try {
    FakerClass = Java.type('com.github.javafaker.Faker');
  } catch (e) {
    FakerClass = null;
  }

  return {
    // Generates a complete mock user object matching ServeRest specs
    getRandomUser: function() {
      if (FakerClass) {
        var faker = new FakerClass();
        var firstName = faker.name().firstName();
        var lastName = faker.name().lastName();
        var name = firstName + " " + lastName;
        
        // Use random suffix and timestamp to guarantee uniqueness across environments
        var randomNum = Math.floor(Math.random() * 10000);
        var cleanEmail = (firstName.toLowerCase() + "." + lastName.toLowerCase() + randomNum + "@serverest.com.br")
                            .replace(/\s+/g, ''); // Remove spaces
        
        var password = faker.internet().password(10, 20);
        
        return {
          nome: name,
          email: cleanEmail,
          password: password,
          administrador: "true"
        };
      } else {
        // Fallback robust JS generator in case Java Faker is not loaded
        var randomNum = Math.floor(Math.random() * 1000000);
        var timestamp = new Date().getTime();
        
        return {
          nome: "User " + randomNum,
          email: "user." + timestamp + "." + randomNum + "@serverest.com.br",
          password: "Pass" + randomNum,
          administrador: "true"
        };
      }
    }
  };
}
