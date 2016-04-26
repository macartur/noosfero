Elasticsearch Plugin
====================

Atualmente estamos executando o elasticsearch na branch: elasticsearch

Estamos utilizando a versão mais recente do elasticsearch, versão: 2.3.1

Link para download: https://www.elastic.co/downloads/elasticsearch

Passos para executar o Noosfero com o elasticsearch

- Instale o elasticsearch
- Inicializar o serviço do elasticsearch
- Instalar as gem's do plugin. Caso tenha problemas com esse passoi, copie
  as gem's do Gemfile do plugin para o core e execute o comando 'bundle install'
- Habilitar o plugin do elasticsearch
- Confira se executou o comando 'rake db:test:prepare' para preparar o banco
  de dados para testes
- Execute o teste unitário 'index_models_test.rb' para verificar se as
  models do Noosfero foram indexadas no elasticsearch
- Popule o banco de dados com Person, Community e Article, se quiser
  apenas execute o script sample-profiles do core do Noosfero
- Rode o servidor do Noosfero
- Acesse o link 'http://localhost:3000/plugin/elasticsearch/search'
- O link citado acima se trata da pagina de busca utilizando o elasticsearch
