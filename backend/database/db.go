package database

import (
	"fmt"
	"mgr_base/backend/config"
	"mgr_base/backend/models"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var DB *gorm.DB

func InitDB() {
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local",
		config.AppConfig.DBUser,
		config.AppConfig.DBPassword,
		config.AppConfig.DBHost,
		config.AppConfig.DBPort,
		config.AppConfig.DBName,
	)

	var err error
	DB, err = gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		panic(fmt.Sprintf("Failed to connect database: %v", err))
	}

	// 自动迁移
	DB.AutoMigrate(
		&models.User{},
		&models.Role{},
		&models.Permission{},
		&models.Resource{},
		&models.Log{},
		&models.IPAccess{},
		&models.DictType{},
		&models.DictItem{},
		&models.Config{},
		&models.Notice{},
		&models.NoticeRead{},
	)

	// 初始化默认数据
	initDefaultData()
}

func initDefaultData() {
	// 创建默认管理员角色
	var adminRole models.Role
	if DB.Where("name = ?", "admin").First(&adminRole).Error != nil {
		adminRole = models.Role{
			Name:        "admin",
			Description: "系统管理员",
		}
		DB.Create(&adminRole)
	}

	// 创建默认管理员用户
	var adminUser models.User
	if DB.Where("username = ?", "admin").First(&adminUser).Error != nil {
		adminUser = models.User{
			Username: "admin",
			Password: hashPassword("admin123"), // 默认密码
			Email:    "admin@example.com",
			RoleID:   adminRole.ID,
		}
		DB.Create(&adminUser)
	}

	// 创建默认站点名称配置
	var siteNameConfig models.Config
	if DB.Where("`key` = ?", "site_name").First(&siteNameConfig).Error != nil {
		siteNameConfig = models.Config{
			Key:         "site_name",
			Value:       "管理系统",
			Label:       "站点名称",
			Type:        "text",
			Group:       "system",
			Description: "系统展示名称",
			Sort:        1,
			Status:      1,
		}
		DB.Create(&siteNameConfig)
	}
}

func hashPassword(password string) string {
	// 使用bcrypt进行密码哈希
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return password
	}
	return string(bytes)
}
