Feature: API de Usuarios - ServeRest

  Background:
    * url baseUrl
    * def Generator = call read('classpath:helpers/DataGenerator.js')
    * def userSchema = read('classpath:schemas/user-schema.json')

  Scenario: CRUD completo de usuario y validacion de email duplicado
    # POST /usuarios - Registrar usuario 
    * def userData = Generator.getRandomUser()
    * def nome = userData.nome
    * def email = userData.email
    * def password = userData.password
    * def administrador = userData.administrador
    Given path 'usuarios'
    And request read('classpath:payloads/user-request.json')
    When method post
    Then status 201
    And match response.message == 'Cadastro realizado com sucesso'
    And match response._id == '#present'
    And match response._id == '#string'
    * def userId = response._id
    # POST /usuarios - Intentar crear con email duplicado (Caso Negativo)
    * def dupPayload = read('classpath:payloads/user-request.json')
    * def dupData = Generator.getRandomUser()
    * set dupPayload.nome = dupData.nome
    * set dupPayload.password = dupData.password
    Given path 'usuarios'
    And request dupPayload
    When method post
    Then status 400
    And match response.message == 'Este email já está sendo usado'
    # GET /usuarios/{_id} - Buscar usuario por ID 
    Given path 'usuarios', userId
    When method get
    Then status 200
    And match response == userSchema
    And match response.nome == nome
    And match response.email == email
    # PUT /usuarios/{_id} - Actualizar usuario
    * def nome = 'Actualizado ' + nome
    Given path 'usuarios', userId
    And request read('classpath:payloads/user-request.json')
    When method put
    Then status 200
    And match response.message == 'Registro alterado com sucesso'
    # DELETE /usuarios/{_id} - Eliminar usuario
    Given path 'usuarios', userId
    When method delete
    Then status 200
    And match response.message == 'Registro excluído com sucesso'

  Scenario: Listar todos los usuarios registrados (GET)
    # GET /usuarios - Listar todos los usuarios
    Given path 'usuarios'
    When method get
    Then status 200
    And match response.quantidade == '#number'
    And match response.usuarios == '#[]'

  Scenario: Intentar buscar un usuario con ID inexistente (GET - Negativo)
    # GET /usuarios/{_id} - Buscar ID no existente (Caso Negativo)
    Given path 'usuarios', 'abcde12345fghij6'
    When method get
    Then status 400
    And match response.message == 'Usuário não encontrado'
