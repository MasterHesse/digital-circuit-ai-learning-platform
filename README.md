# ⚡ DigLearn（数字电路 AI 学习平台）

![Vue.js](https://img.shields.io/badge/Vue%203-4FC08D?style=for-the-badge&logo=vuedotjs&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-6DB33F?style=for-the-badge&logo=springboot&logoColor=white)
![Neo4j](https://img.shields.io/badge/Neo4j-008CC1?style=for-the-badge&logo=neo4j&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)

> **最后更新**：2026-02-23  
> **后端架构**：Spring Boot + Neo4j（知识图谱）+ PostgreSQL（题库/关卡/作答记录）  
> **前端架构**：Vue 3 + Vite

**DigLearn** 是一个专为数字电路学习打造的练习与仿真平台，提供从知识点图谱查询、题库练习（支持章节、推荐、错题与巩固模式），到在线关卡挑战与自动判题的完整学习闭环。

---

## 📑 目录

- [✨ 功能概览](#-功能概览)
- [🛠️ 技术栈](#️-技术栈)
- [📂 仓库结构](#-仓库结构)
- [🚀 快速开始](#-快速开始)
- [⚙️ 配置说明](#️-配置说明)
- [🌐 端口速查表](#-端口速查表)
- [🔌 API 接口（节选）](#-api-接口节选)
- [📊 数据模型摘要](#-数据模型摘要)
- [📄 许可证 (License)](#-许可证-license)

---

## ✨ 功能概览

### 🧠 知识点图谱（Neo4j）
- **详情查询**：快速获取知识点详细解析。
- **前置展开**：按深度动态展开前置依赖知识点，构建学习路径。

### 📝 练习中心（题库 + 作答状态）
- **章节练习**：按知识点或分类进行针对性训练。
- **智能推荐**：基于错题池和学习进度推送补充练习。
- **自动判分**：支持提交作答并自动评分，兼容主客观题型。
- **错题巩固**：错题自动触发巩固练习，并推荐先学知识点。

### 🔌 电路仿真与关卡（PostgreSQL）
- **关卡挑战**：提供丰富的在线电路关卡列表与详情。
- **在线判题**：提交电路设计，系统自动判题并记录通关状态。

### 👤 用户管理
- **个性化记录**：支持用户创建与查询，为后续个性化学习轨迹提供数据支撑。

---

## 🛠️ 技术栈

### 🔙 Backend（`/backend`）
- **核心框架**：Java 21, Spring Boot `3.5.10`
- **Spring 生态**：Web / Validation / Security / Actuator
- **数据持久化**：
  - Spring Data Neo4j（知识点图谱）
  - Spring Data JPA + PostgreSQL（题库/关卡/作答记录等）
- **接口文档**：OpenAPI / Swagger UI (`springdoc-openapi-starter-webmvc-ui:2.8.0`)

### 🎨 Frontend（`/frontend`）
- **核心框架**：Vue 3 + Vite
- **开发语言**：TypeScript（全面使用 `<script setup lang="ts">`）
- **核心页面**：`Login`（登录）、`Practice`（练习）、`OnlineVerilogEditorPage`（在线仿真）、`Profile`（个人中心）

### 🏗️ Infra（`/infra`）
- **容器化**：Docker Compose
- **关系型数据库**：PostgreSQL（镜像：`pgvector/pgvector:pg16`）
- **图数据库**：Neo4j 5
- **中间件（预留）**：Redis 7, RabbitMQ

---

## 📂 仓库结构

```bash
.
├── backend/                # ☕ Spring Boot 后端源码
├── frontend/               # ⚡ Vue3 + Vite 前端源码
├── infra/                  # 🐳 docker-compose 与环境变量配置
└── docs/                   # 📚 项目文档与 Neo4j seed 脚本等
```

---

## 🚀 快速开始

### 0️⃣ 前置要求
- Docker / Docker Compose
- JDK 21
- Node.js（建议 18+ 或 20+）
- *(可选)* Neo4j Browser / pgAdmin 等数据库客户端

### 1️⃣ 启动基础设施
进入 `infra/` 目录，启动数据库与中间件：

```bash
cd infra
docker compose --env-file .env up -d
docker compose ps
```

### 2️⃣ 启动后端服务
进入 `backend/` 目录，运行 Spring Boot：

```bash
cd backend
./mvnw spring-boot:run
```
> 后端服务默认监听：`http://localhost:8080`

### 3️⃣ 启动前端服务
进入 `frontend/` 目录，安装依赖并启动：

```bash
cd frontend
npm install
npm run dev
```
> 前端开发服务器默认监听：`http://localhost:5173`

---

## ⚙️ 配置说明

### 🐳 Infra `.env`
**路径**：`infra/.env`

```dotenv
POSTGRES_DB=diglearn
POSTGRES_USER=postgres
POSTGRES_PASSWORD=123456

NEO4J_AUTH=neo4j/neo4j_pwd

RABBITMQ_DEFAULT_USER=diglearn
RABBITMQ_DEFAULT_PASS=123456
```
> ⚠️ **安全提示**：以上账号密码仅供本地开发使用，生产环境请务必替换并妥善保管密钥。

### ☕ 后端 `application.yml`
**路径**：`backend/src/main/resources/application.yml`

- **后端端口**：`8080`
- **Neo4j**：`bolt://localhost:7687`（账号 `neo4j` / `neo4j_pwd`）
- **PostgreSQL**：`jdbc:postgresql://localhost:5433/diglearn`（账号 `postgres` / `123456`）
- **Swagger UI**：`/swagger-ui`
- **OpenAPI**：`/v3/api-docs`

---

## 🌐 端口速查表

| 组件 | 地址 / 端口 | 用途说明 |
| :--- | :--- | :--- |
| **Backend** | `http://localhost:8080` | 业务 API 接口 |
| **Swagger UI** | `http://localhost:8080/swagger-ui` | 可视化 API 文档 |
| **OpenAPI JSON**| `http://localhost:8080/v3/api-docs` | API 文档数据源 |
| **Actuator** | `http://localhost:8080/actuator/health`| 服务健康检查 |
| **Neo4j Browser**| `http://localhost:7474` | 图数据库 Web 控制台 |
| **Neo4j Bolt** | `bolt://localhost:7687` | 后端连接图数据库端口 |
| **PostgreSQL** | `localhost:5433` | 宿主机映射端口 (JPA 存档) |
| **Redis** | `localhost:6380` | 缓存服务 (预留) |
| **RabbitMQ** | `localhost:5672` | AMQP 消息队列 (预留) |
| **RabbitMQ UI** | `http://localhost:15672` | 消息队列管理界面 |
| **Frontend** | `http://localhost:5173` | Vite 前端开发服务器 |

---

## 🔌 API 接口（节选）

> 💡 以下接口均以 `http://localhost:8080` 为基址。

### 📚 知识点（KnowledgePoint）
- `GET /api/kp/{kpId}`：获取知识点详情
- `GET /api/kp/{kpId}/prereqs?depth=1..3`：按深度展开前置知识点

**调用示例**：
```bash
curl -s http://localhost:8080/api/kp/DL-080
curl -s "http://localhost:8080/api/kp/DL-080/prereqs?depth=3"
```

### 🎮 关卡（Levels）
- `GET /api/levels`：获取关卡摘要列表
- `GET /api/levels/{code}`：获取特定关卡详情
- `POST /api/levels/{code}/judge`：提交电路并判题
- `GET /api/levels/{code}/pass`：查询通关状态（支持 Header `X-User-Id` 或 Query `userId`）

**调用示例**：
```bash
curl -s http://localhost:8080/api/levels
curl -s http://localhost:8080/api/levels/LEVEL-001
```

### 👥 用户（Users）
- `GET /api/users`：获取用户列表
- `POST /api/users`：创建新用户（可选指定 `userId`）

### 🎯 练习中心（前端对接参考）
前端 `Practice.vue` 页面主要依赖以下接口：
- `GET /api/practice/chapters?category=...`
- `GET /api/practice/chapters/{kpId}/questions`
- `GET /api/practice/recommended`
- `GET /api/questions/{questionId}`
- `POST /api/questions/{questionId}/submit`
- `GET /api/practice/reinforcement/{questionId}?count=2`
- `POST /api/practice/recommended/{questionId}/mastered`

---

## 📊 数据模型摘要

### 🕸️ Neo4j（知识点图）
- **节点 (Node)**：`(k:KnowledgePoint { kpId, title, category, difficulty })`
- **关系 (Relationship)**：`(A)-[:PREREQ]->(B)` —— 表示 **A 依赖 B**（即 B 是 A 的前置知识点）。

### 🗄️ PostgreSQL（题库/作答/关卡）
- **题库系统**：`questions`, `tags`, `question_tag_map`, `tag_kp_map`
- **作答状态**：`question_attempts`, `user_question_state`
- **关卡系统**：`levels`, `level_test_cases`, `level_test_steps`, `level_pass_records`

---

## 📄 许可证 (License)

本项目采用 [MIT License](https://opensource.org/licenses/MIT) 开源许可证。

```text
MIT License

Copyright (c) 2026 DigLearn

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---
