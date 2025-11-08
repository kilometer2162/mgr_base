package main

import (
	"mgr_base/backend/config"
	"mgr_base/backend/database"
	"mgr_base/backend/router"
	"mgr_base/backend/utils"

	"github.com/gin-gonic/gin"
)

func main() {
	// 初始化配置
	config.InitConfig()

	// 初始化数据库
	database.InitDB()

	// 初始化Redis
	database.InitRedis()

	// 初始化路由
	r := gin.Default()

	// 配置CORS
	r.Use(utils.CORSMiddleware())

	// 注册路由
	router.SetupRoutes(r)

	// 启动服务器
	r.Run(":8080")
}

