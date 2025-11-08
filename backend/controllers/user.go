package controllers

import (
	"mgr_base/backend/database"
	"mgr_base/backend/models"
	"mgr_base/backend/utils"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func GetUsers(c *gin.Context) {
	var users []models.User
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "10"))
	offset := (page - 1) * pageSize

	var total int64
	database.DB.Model(&models.User{}).Count(&total)
	database.DB.Preload("Role").Offset(offset).Limit(pageSize).Find(&users)

	c.JSON(http.StatusOK, gin.H{
		"data":  users,
		"total": total,
		"page":  page,
		"page_size": pageSize,
	})
}

func GetUser(c *gin.Context) {
	id := c.Param("id")
	var user models.User
	if err := database.DB.Preload("Role").First(&user, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}
	c.JSON(http.StatusOK, user)
}

func CreateUser(c *gin.Context) {
	var user models.User
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 密码哈希
	hashedPassword, err := utils.HashPassword(user.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "密码加密失败"})
		return
	}
	user.Password = hashedPassword

	if err := database.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "创建用户失败"})
		return
	}

	c.JSON(http.StatusOK, user)
}

func UpdateUser(c *gin.Context) {
	id := c.Param("id")
	var user models.User
	if err := database.DB.First(&user, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}

	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 如果提供了密码，进行哈希
	if user.Password != "" {
		hashedPassword, err := utils.HashPassword(user.Password)
		if err == nil {
			user.Password = hashedPassword
		}
	}

	database.DB.Save(&user)
	c.JSON(http.StatusOK, user)
}

func DeleteUser(c *gin.Context) {
	id := c.Param("id")
	database.DB.Delete(&models.User{}, id)
	c.JSON(http.StatusOK, gin.H{"message": "删除成功"})
}

