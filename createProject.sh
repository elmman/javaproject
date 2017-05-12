#!/bin/bash

#项目名，首字母大写
projectName=Demo
#默认库名
databaseName=demo
#小写项目名
lcProjectName=$(echo $projectName | tr [A-Z] [a-z])
#基础包名
package="com.elmman.service.${lcProjectName}"
#api基础模块
module_list=('Api' 'Common' 'Core' 'Domain' 'Query' 'Repository')

function createApiProject() {

	createRootProject

	createApiModules

	# gradle
}


function createRootProject() {
	mkdir -p ${lcProjectName}
	cd ${lcProjectName}
	gradle init
	#加载模板配置文件
	sed "s/project_name/${lcProjectName}/g" ../template/config/build.gradle.example > build.gradle
}

function createApiModules() {
	#创建文档目录
	mkdir -p docs;

	for module in ${module_list[@]}
	do
		lcModule=$(echo ${module} | tr [A-Z] [a-z])
		echo "\ninclude '${lcProjectName}-${lcModule}'" >> settings.gradle
		#创建包
		mkdir -p ${lcProjectName}-${lcModule}/src/{main,test}/java/${package}.${lcModule}
		#创建模板ApplicationContext.java
		touch ${lcProjectName}-${lcModule}/src/main/java/${package}.${lcModule}/${projectName}${module}ApplicationContext.java
		echo "package ${package}.${lcModule};\n" >> ${lcProjectName}-${lcModule}/src/main/java/${package}.${lcModule}/${projectName}${module}ApplicationContext.java
		echo "\nimport org.springframework.boot.autoconfigure.SpringBootApplication;\n" >> ${lcProjectName}-${lcModule}/src/main/java/${package}.${lcModule}/${projectName}${module}ApplicationContext.java
		echo "@SpringBootApplication" >> ${lcProjectName}-${lcModule}/src/main/java/${package}.${lcModule}/${projectName}${module}ApplicationContext.java
		echo "public class ${projectName}${module}ApplicationContext {\n" >> ${lcProjectName}-${lcModule}/src/main/java/${package}.${lcModule}/${projectName}${module}ApplicationContext.java
		echo "}\n" >> ${lcProjectName}-${lcModule}/src/main/java/${package}.${lcModule}/${projectName}${module}ApplicationContext.java
		#创建配置目录
		mkdir -p ${lcProjectName}-${lcModule}/src/main/resources/{base,development,production,testing}
		#创建base配置文件
		touch ${lcProjectName}-${lcModule}/src/main/resources/base/${lcProjectName}-${lcModule}-base.properties
		#创建env配置文件
		touch ${lcProjectName}-${lcModule}/src/main/resources/{development,production,testing}/${lcProjectName}-${lcModule}-env.properties

		doSpecialInit ${module} ${lcModule}
	done
}

function doSpecialInit() {
	case $1 in
		'Api') echo doApiSpecialInit $1 $2
		;;
		'Common') echo 'Common'
		;;
		'Core') echo 'Core'
		;;
		'Domain') echo 'Domain'
		;;
		'Query') echo 'Query'
		;;
		'Repository') doRepositorySpecialInit $1 $2
		;;
		*) echo '哈哈哈哈哈哈,笑死我了!'
		;;
	esac
}

function doApiSpecialInit() {
	module=$1
	lcModule=$2

	
}

function doRepositorySpecialInit() {
	module=$1
	lcModule=$2

	#repository基本目录
	mkdir -p ${lcProjectName}-${lcModule}/src/main/java/${package}.${module}/{config,datasource,mapper,repository}

	sed "s/project_package/${package}/g" ../template/class/DatabaseConfig.java.example | sed "s/project_database/${databaseName}/g" > ${lcProjectName}-${lcModule}/src/main/java/${package}.${module}/config/DatabaseConfig.java

	sed "s/project_package/${package}/g" ../template/class/H2DataSource.java.example | sed "s/project_database/${databaseName}/g" > ${lcProjectName}-${lcModule}/src/main/java/${package}.${module}/datasource/H2DataSource.java

	sed "s/project_package/${package}/g" ../template/class/MySQLDataSource.java.example > 	${lcProjectName}-${lcModule}/src/main/java/${package}.${module}/datasource/MySQLDataSource.java

	sed "s/project_package/${package}/g" ../template/class/RepositoryApplicationContext.java.example | sed "s/lc_project_name/${lcProjectName}/g" | sed "s/project_name/${projectName}/g" > ${lcProjectName}-${lcModule}/src/main/java/${package}.${module}/${projectName}${module}ApplicationContext.java

	#base config
	#生成mybatis generator 配置文件
	mkdir -p ${lcProjectName}-${lcModule}/src/main/resources/generator
	sed "s/project_package/${package}/g" ../template/config/generatorConfig.xml.example | sed "s/project_name/${lcProjectName}/g" | sed "s/project_database/${databaseName}/g" > ${lcProjectName}-${lcModule}/src/main/resources/generator/generatorConfig.xml
	# cp ../template/config/repository.build.gradle.example ${lcProjectName}-${lcModule}/build.gradle

	touch ${lcProjectName}-${lcModule}/src/main/resources/H2${databaseName}Schema.sql

	mkdir -p ${lcProjectName}-${lcModule}/src/main/resources/base/${package}.${lcModule}.mapper

	#development config
	echo "
	${databaseName}.jdbc.url=jdbc:mysql://localhost:3306/${databaseName}?zeroDateTimeBehavior=convertToNull&useSSL=false&useUnicode=true&characterEncoding=UTF-8
	${databaseName}.jdbc.username=root
	${databaseName}.jdbc.password=123456
	" >> ${lcProjectName}-${lcModule}/src/main/resources/development/${lcProjectName}-${lcModule}-env.properties
}

createApiProject
