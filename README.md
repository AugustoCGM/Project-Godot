![Banner do Projeto](docs/media/banner.png)

# 📝 Dev Log: Projeto Plataforma (Godot)

Bem-vindo ao dev log oficial deste projeto! Este repositório documenta a jornada de desenvolvimento de um jogo de plataforma criado com o objetivo de colocar em prática os conceitos estudados na engine Godot.

> **Nota inicial:** O projeto começou de forma diferente e passou por algumas evoluções importantes de escopo e identidade visual até chegar ao estado atual. Abaixo está o registro cronológico do desenvolvimento.

---

## 🗂️ Índice
* [Dia 1: O Ponto de Partida (O Incidente "Dinomorph")](#-dia-1-o-ponto-de-partida-o-incidente-dinomorph)
* [Dia 2: A Chegada de Bob e a Exploração de Câmera](#-dia-2-a-chegada-de-bob-e-a-exploração-de-câmera)
* [Dia 3: O Hamster na Bola, o Nascimento do "Blob" e Texturas](#-dia-3-o-hamster-na-bola-o-nascimento-do-blob-e-texturas)
* [Dia 4: Ambientação, Camadas e o Efeito Parallax](#-dia-4-ambientação-camadas-e-o-efeito-parallax)
* [Dia 5: Pouco Tempo, Nova Cena e Água Animada](#-dia-5-pouco-tempo-nova-cena-e-água-animada)
* [Tecnologias e Ferramentas](#%EF%B8%8F-tecnologias-e-ferramentas)

---

## 🦖 Dia 1: O Ponto de Partida (O Incidente "Dinomorph")

O projeto começou no dia 5 com a ideia inicial de criar um endless runner com dinossauros (estilo o jogo do dinossauros do Google Chrome). Cheguei a estruturar conceitos visuais e sprites iniciais para esse projeto (que se chama provisoriamente de Dinomorph e continua vivo, voltando à ativa assim que este jogo de plataforma for concluído).

Como o curso que estou seguindo aborda o desenvolvimento de jogos de plataforma, decidi pivotar o foco do projeto para aplicar diretamente os novos conhecimentos.

**Foco do dia:** 
* Aprendizado dos fundamentos da Godot (scripts básicos, sistema de animação e colisões).

**Resultados ao fim do dia:**
* Criação de um protótipo de terreno usando caixas de colisão básicas (sem texturas).
* Implementação do player temporário (ainda um dinossauro) com estados de animação para Static, Walking e Jumping.

### 📸 Mídia do Dia 1
* **Concepts do dino:** ![DINO Concepts](docs/media/imagem_dino.png)

---

## 😐 Dia 2: A Chegada de Bob e a Exploração de Câmera

O segundo dia foi de "pouco avanço" estrutural devido à mudança de direção. Para não gastar os sprites dos dinossauros e acabar criando algo reciclado, decidi trazer um personagem de outro projeto futuro do JAM labs: o Bob.

O Bob foi originalmente criado para ser o protagonista do Desem Forca (evolução direta e mobile do projeto anterior Em Forca, já concluído e disponível na Play Store). A ideia inicial era introduzir o humor e a falta de carisma dele aqui. Porém, com minha experiência de 1 hora de Aseprite, percebi que ainda não tenho técnica para animar um personagem tão detalhado (sei da regra de fazer funcionar primeiro e deixar bonito depois, mas definir o personagem principal do jogo é importante para saber como o jogo deve se comportar e eu não garanto que eu vá conseguir aprender a fazer bons sprites até o final do desenvolvimento, até pq, esse não é o foco do projeto).

Ainda assim, criei os sprites de Standing, Walking e Jumping para ele (que ficaram até que legais, eu acho).

**Foco do dia:**
* Testar os limites com o Aseprite criando os sprites do Bob.
* Experimentação com caixas de colisão para criar uma pseudo-fase explorável.
* Implementação do sistema de câmera centralizada com efeito smooth.

### 📸 Mídia do Dia 2
* **Concepts do Bob:** ![Bob Concepts](docs/media/bob_concepts.png)
* **Spritesheet do Bob:** ![Bob Sprites](docs/media/bob_sprites.png)
* **Gameplay com o Bob:** ![Bob Sprites](docs/media/bob_GP.png)

---

## 🟢 Dia 3: O Hamster na Bola, o Nascimento do "Blob" e Texturas

No terceiro dia, pensei em mudar de rota novamente: imaginei um jogo sobre um hamster fugindo de casa em sua bola, focando em momentum e alta velocidade usando o terreno. Novamente, vi que o escopo e a criação de sprites fugiam da minha capacidade técnica atual.

Explorando minha galeria de concepts antigos (inclusive ideias descartadas durante a criação do Bob), encontrei o personagem perfeito: uma criatura em formato de bolha preta com braços flutuantes e uma carinha fofa. Ele é carismático, fácil de animar e encaixou perfeitamente no projeto de plataforma.

**Foco do dia:**
* Criação dos sprites definitivos para o personagem (incluindo a animação de Falling).
* Refinamento da física do personagem.
* Estudos iniciais sobre terreno, posicionamento do eixo Z e ajustes finos na câmera.
* Primeira aplicação de texturas no mapa.

### 📸 Mídia do Dia 3
* **Sprites do novo personagem (Blob):** ![Blob Sprites](docs/media/blob_sprites.png)
* **Primeira versão do terreno de testes:** ![Blob Sprites](docs/media/betaterrainV1.png)

---

## 🌄 Dia 4: Ambientação, Camadas e o Efeito Parallax

O quarto dia foi focado 100% em ambientação e em entender como estruturar um mapa de verdade. Percebi rápido que, para um jogo de plataforma focado em exploração (que é o caminho que quero seguir com esse projeto ainda sem nome), dividir o mapa em camadas não é só capricho, é essencial.

Também assimilei bem melhor a lógica de tilesets, a importância de separar tiles em objetos específicos e como organizar tudo isso de forma limpa na Godot. Com isso, resolvi reestruturar o mapa todo: mantive o mesmo layout que já tinha gostado, mas refiz do zero aplicando camadas organizadas, refinando as hitboxes de colisão, adicionando detalhes de cenário para dar mais vida e seguindo boas práticas de level design.

Para fechar o dia com chave de ouro, implementei um background definitivo e configurei o efeito de Parallax, aplicando diferentes intensidades de movimento de acordo com a profundidade e distância de cada camada. A sensação de profundidade mudou completamente o jogo! (mas definitivamente, minhas tecnicas com o paralax ainda tem muito a melhorar)

**Foco do dia:**
* Estudo prático de Tilemaps, divisão de objetos em tiles e organização em camadas (layers).
* Reestruturação completa do mapa de testes mantendo o layout, mas com hitboxes refinadas e detalhes de ambientação.
* Implementação de background com Parallax em múltiplas velocidades para criar sensação real de profundidade.

### 📸 Mídia do Dia 4
* **Mapa reestruturado com camadas:** ![Mapa Reestruturado](docs/media/mapa_v2_camadas.png)
* **Camadas de Parallax, mapa e Ambientação:** ![Parallax e Background](docs/media/parallax_ambientacao.png)

---

## 🌊 Dia 5: Pouco Tempo, Nova Cena e Água Animada

O quinto dia acabou sendo mais enxuto por pura falta de tempo, mas ainda assim deu para aprender algo muito massa. Como o tempo de tela foi curto, o foco acabou sendo bem cirúrgico: entender como funciona a animação de tiles na Godot.

Comecei montando uma nova cena de testes bem rápida para não bagunçar o mapa anterior. Depois de apanhar um pouquinho para pegar a lógica (e tentar relembrar tudo que eu tinha aprendido nos dias anteriores), consegui criar os frames e aplicar animação para a água do cenário. Mesmo parecendo um detalhe pequeno, foi bacaninha aprender a animar isso (Quero tentar fazer isso para simular uns efeitos de vento nas plantas e tal) e acho que fecha bem os estudos com tilesets animados.

**Foco do dia:**
* Criação de uma nova cena de testes ágil para prototipagem rápida.
* Estudo e implementação de animação de tiles dentro do TileMap.
* Adição de água animada ao cenário.

### 📸 Mídia do Dia 5
* **Nova cena de testes e Água animada:** ![Agua Animada](docs/media/agua_animada.gif)

---

## 🛠️ Tecnologias e Ferramentas
* **Engine:** Godot Engine
* **Arte / Animação:** Aseprite
* **Organização:** JAM labs