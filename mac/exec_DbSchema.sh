#!/usr/bin/env bash
javac -cp /Users/macrosea/ws/vipshop/tmp/codegen-2.0.6/lib/:./ -d .  DbSchema.java
java -cp /Users/macrosea/ws/vipshop/tmp/codegen-2.0.6/lib/mysql-connector-java-5.1.18.jar:.  DbSchema
rm *.class
