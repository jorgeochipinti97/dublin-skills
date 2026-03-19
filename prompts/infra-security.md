# infra-security

## Activation Prompts

```
Diseñá la infraestructura para [producto/servicio] desde cero en AWS considerando costos y escalabilidad
```

```
Revisá esta arquitectura y decime los riesgos de seguridad: [descripción]
```

```
Necesito montar un servidor [nginx/Docker/VPS] con SSL y hardening básico
```

```
Quiero construir una plataforma de AI as a Service tipo [descripción], ¿cómo la diseñarías?
```

```
Ayudame a optimizar los costos de esta infra en AWS, estoy gastando $[X]/mes
```

## Example Use Cases

- Diseñar un "Vercel para agentes" usando AWS Bedrock con multi-tenancy
- Configurar una instancia EC2 con nginx, SSL y Docker para producción
- Auditar políticas IAM y encontrar permisos excesivos
- Elegir entre Fargate vs Lambda vs EC2 para una API con tráfico variable
- Montar un stack de inferencia propio con vLLM en GPU para reducir costos de Bedrock
- Diseñar una arquitectura RAG multi-tenant con pgvector y control de acceso por tenant
- Calcular el costo mensual estimado de una arquitectura propuesta
- Hardening de un VPS Linux: SSH, firewall, fail2ban, secrets
