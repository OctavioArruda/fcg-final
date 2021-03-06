#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpolação da posição global e a normal de cada vértice, definidas em
// "shader_vertex.glsl" e "main.cpp".
in vec4 position_world;
in vec4 normal;
// Posição do vértice atual no sistema de coordenadas local do modelo.
in vec4 position_model;

// Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
in vec2 texcoords;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto está sendo desenhado no momento
#define CAR 0
#define GROUND 1
#define SPHERE 2
#define BUNNY 3

uniform int object_id;

// Parâmetros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

// Variáveis para acesso das imagens de textura
uniform sampler2D TextureImage0; // cow-texture.jpg
uniform sampler2D TextureImage1; // stone 
uniform sampler2D TextureImage2; //
// O valor de saída ("out") de um Fragment Shader é a cor final do fragmento.
out vec3 color;

// Constantes
#define M_PI   3.14159265358979323846
#define M_PI_2 1.57079632679489661923

void main()
{
    // Obtemos a posição da câmera utilizando a inversa da matriz que define o
    // sistema de coordenadas da câmera.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;

    vec4 light_pos = vec4(0.0f,10.0f,0.0f,1.0f);

    // O fragmento atual é coberto por um ponto que percente à superfície de um
    // dos objetos virtuais da cena. Este ponto, p, possui uma posição no
    // sistema de coordenadas global (World coordinates). Esta posição é obtida
    // através da interpolação, feita pelo rasterizador, da posição de cada
    // vértice.
    vec4 p = position_world;

    // Normal do fragmento atual, interpolada pelo rasterizador a partir das
    // normais de cada vértice.
    vec4 n = normalize(normal);

    // Vetor que define o sentido da fonte de luz em relação ao ponto atual.
    vec4 l = normalize(light_pos - p);

    // Vetor que define o sentido da câmera em relação ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // Vetor que define o sentido da reflexão especular ideal.
    vec4 r = -l + 2 * n * dot(n, l);

    // Parâmetros que definem as propriedades espectrais da superfície
    vec3 Kd; // Refletância difusa que será obtida da imagem de textura
    vec3 Ks; // Refletância especular
    vec3 Ka; // Refletância ambiente
    float q; // Expoente especular para o modelo de iluminação de Phong

    // Coordenadas de textura U e V
    float U = 0.0;
    float V = 0.0;

    if ( object_id == CAR )
    {
        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        U = (position_model.x - minx) / (maxx - minx);
        V = (position_model.z - minz) / (maxz - minz);

        Kd = texture(TextureImage0, vec2(U,V)).rgb;

        Ka = vec3(0.2,0.1,0.1);
        Ks = vec3(0.0,0.0,0.0);
        q = 30.0;
    } else if( object_id == GROUND )
    {
        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        U = (position_model.x - minx)/(maxx - minx);
        V = (position_model.z - minz)/(maxz - minz);

        Kd = texture(TextureImage1, vec2(U,V)).rgb;
        Ka = vec3(0.2,0.1,0.1);
        Ks = vec3(0.0,0.0,0.0);
        q = 30.0; 
    } else if( object_id == SPHERE )
    {
        vec4 bbox_center = (bbox_min + bbox_max) / 2.0;

        float sphere_radius = length(position_model - bbox_center);

        float theta = atan(position_model.x,position_model.z);
        float phi = asin(position_model.y/sphere_radius);

        U = (theta + M_PI)/(2*M_PI);
        V = (phi + (M_PI/2))/M_PI;

        Kd = texture(TextureImage2, vec2(U,V)).rgb;
        Ka = vec3(0.2,0.1,0.1);
        Ks = vec3(0.0,0.0,0.0);
        q = 30.0; 
    }else if( object_id == BUNNY )
    {
        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        U = (position_model.x - minx) / (maxx - minx);
        V = (position_model.z - minz) / (maxz - minz);

        Kd = texture(TextureImage2, vec2(U,V)).rgb;

        Ka = vec3(0.2,0.1,0.1);
        Ks = vec3(0.0,0.0,0.0);
        q = 10.0; 
    } else
    {
        Kd = vec3(0.0,0.0,0.0);
        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 1.0;
    }
    
    // Espectro da fonte de iluminação
    vec3 I = vec3(1.0,1.0,1.0);

    // Espectro da luz ambiente
    vec3 Ia = vec3(0.1,0.1,0.1);

    // Termo difuso utilizando a lei dos cossenos de Lambert
    vec3 lambert_diffuse_term = Kd*I*max(0,dot(n,l));

    // Termo ambiente
    vec3 ambient_term = Ka*Ia;

    vec4 h = l + v;

    h = h/length(h);

    // Termo especular utilizando o modelo de iluminação de Blinn - Phong
    vec3 blinn_phong_specular_term = Ks*I*pow(max(0,dot(n,h)),q);

    // Cor final do fragmento calculada com uma combinação dos termos difuso,
    // especular, e ambiente. Veja slide 133 do documento "Aula_17_e_18_Modelos_de_Iluminacao.pdf".
    color = lambert_diffuse_term + ambient_term + blinn_phong_specular_term;

    // Cor final com correção gamma, considerando monitor sRGB.
    // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
    color = pow(color, vec3(1.0,1.0,1.0)/2.2);
}
