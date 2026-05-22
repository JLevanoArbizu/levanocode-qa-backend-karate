function fn() {
  var env = karate.env;
  karate.log('karate.env system property is:', env);
  
  if (!env) {
    env = 'dev';
  }
  
  var config = {
    env: env,
    baseUrl: 'https://serverest.dev'
  };

  if (env == 'QA') {
    config.baseUrl = 'https://qa.serverest.dev'; 
  } else if (env == 'UAT') {
    config.baseUrl = 'https://uat.serverest.dev';
  } else if (env == 'PROD') {
    config.baseUrl = 'https://serverest.dev';
  }

  karate.configure('connectTimeout', 5000);
  karate.configure('readTimeout', 5000);

  return config;
}
