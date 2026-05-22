@e2e
Feature: API de Usuarios - ServeRest

  Background:
    * url baseUrl
    * def Generator = call read('classpath:helpers/DataGenerator.js')
    * def userSchema = read('classpath:schemas/user-schema.json')

  Scenario: CRUD completo de usuario y validacion de email duplicado
    # POST /usuarios - Registrar usuario
    * def userData = Generator.getRandomUser()
    Given path 'usuarios'
    And request userData
    When method post
    Then status 201
    * print 'RESPONSE POST >>>>>>>>', response
    And match response.message == 'Cadastro realizado com sucesso'

    * def userId = response._id

    # POST /usuarios - Intentar crear con email duplicado
    * def dupPayload = Generator.getRandomUser()
    * set dupPayload.email = userData.email

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
    And match response.nome == userData.nome
    And match response.email == userData.email

    # PUT /usuarios/{_id} - Actualizar usuario
    * set userData.nome = 'Actualizado ' + userData.nome
    Given path 'usuarios', userId
    And request userData
    When method put
    Then status 200
    And match response.message == 'Registro alterado com sucesso'

    # DELETE /usuarios/{_id} - Eliminar usuario
    Given path 'usuarios', userId
    When method delete
    Then status 200
    And match response.message == 'Registro excluído com sucesso'

  @smoke
  Scenario: Listar todos los usuarios registrados (GET)
    # GET /usuarios - Listar todos los usuarios
    Given path 'usuarios'
    When method get
    Then status 200
    * print 'RESPONSE GET ALL USER >>>>>>>', response
    And match response.quantidade == '#number'
    And match response.usuarios == '#[]'
    #And match response.usuarios contains { "nome": "Milosch Marko", "_id": "#present" }
  #@ignore

  @smoke
  Scenario: Intentar buscar un usuario con ID inexistente (GET - Negativo)
    # GET /usuarios/{_id} - Buscar ID no existente (Caso Negativo)
    Given path 'usuarios', 'abcde12345fghij6'
    When method get
    Then status 400
    And match response.message == 'Usuário não encontrado'
