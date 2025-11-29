#!/bin/bash

# Working MongoDB Sample Data Creator
# Creates sample databases with proper authentication

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Creating MongoDB Sample Data...${NC}"

# Get MongoDB pod and credentials
MONGO_POD=$(kubectl get pods -l app=mongodb -o jsonpath='{.items[0].metadata.name}')
ROOT_PASSWORD=$("$SCRIPT_DIR/manage-credentials.sh" --get mongodb_root_password)

echo "Using pod: $MONGO_POD"

# Create sample data using direct insertion commands
echo -e "${YELLOW}Creating learningdb database...${NC}"

kubectl exec "$MONGO_POD" -- mongosh -u admin -p "$ROOT_PASSWORD" --authenticationDatabase admin learningdb --eval "
db.students.insertMany([
  {studentId: 'STU001', name: 'Alice Johnson', age: 20, major: 'Computer Science', gpa: 3.8, email: 'alice@university.edu'},
  {studentId: 'STU002', name: 'Bob Smith', age: 19, major: 'Mathematics', gpa: 3.6, email: 'bob@university.edu'},
  {studentId: 'STU003', name: 'Carol Davis', age: 21, major: 'Physics', gpa: 3.9, email: 'carol@university.edu'},
  {studentId: 'STU004', name: 'David Wilson', age: 22, major: 'Computer Science', gpa: 3.7, email: 'david@university.edu'}
]);

db.courses.insertMany([
  {courseId: 'CS101', name: 'Introduction to Computer Science', department: 'Computer Science', credits: 3, instructor: 'Prof. Johnson'},
  {courseId: 'MATH201', name: 'Calculus II', department: 'Mathematics', credits: 4, instructor: 'Prof. Martinez'},
  {courseId: 'PHYS101', name: 'General Physics I', department: 'Physics', credits: 4, instructor: 'Dr. Chen'},
  {courseId: 'CS201', name: 'Data Structures', department: 'Computer Science', credits: 4, instructor: 'Prof. Johnson'}
]);
"

echo -e "${YELLOW}Creating ecommerce database...${NC}"

kubectl exec "$MONGO_POD" -- mongosh -u admin -p "$ROOT_PASSWORD" --authenticationDatabase admin ecommerce --eval "
db.products.insertMany([
  {productId: 'PROD001', name: 'Wireless Bluetooth Headphones', price: 199.99, category: 'Electronics', brand: 'AudioTech', stock: 50, rating: 4.5},
  {productId: 'PROD002', name: 'Gaming Mechanical Keyboard', price: 149.99, category: 'Electronics', brand: 'GamePro', stock: 25, rating: 4.7},
  {productId: 'PROD003', name: 'Organic Coffee Beans', price: 24.99, category: 'Food & Beverages', brand: 'Mountain Roast', stock: 100, rating: 4.3},
  {productId: 'PROD004', name: 'MongoDB Programming Book', price: 49.99, category: 'Books', brand: 'TechPress', stock: 30, rating: 4.6}
]);

db.customers.insertMany([
  {customerId: 'CUST001', name: 'Emma Thompson', email: 'emma.thompson@email.com', city: 'San Francisco', totalOrders: 3, totalSpent: 599.97},
  {customerId: 'CUST002', name: 'Michael Chen', email: 'michael.chen@email.com', city: 'Los Angeles', totalOrders: 5, totalSpent: 1299.95},
  {customerId: 'CUST003', name: 'Sarah Williams', email: 'sarah.williams@email.com', city: 'New York', totalOrders: 2, totalSpent: 374.98}
]);

db.orders.insertMany([
  {orderId: 'ORD001', customerId: 'CUST001', customerName: 'Emma Thompson', items: [{productId: 'PROD001', name: 'Wireless Bluetooth Headphones', quantity: 1, price: 199.99}], total: 199.99, status: 'delivered', orderDate: new Date('2024-11-01')},
  {orderId: 'ORD002', customerId: 'CUST002', customerName: 'Michael Chen', items: [{productId: 'PROD002', name: 'Gaming Mechanical Keyboard', quantity: 1, price: 149.99}], total: 149.99, status: 'processing', orderDate: new Date('2024-11-15')},
  {orderId: 'ORD003', customerId: 'CUST001', customerName: 'Emma Thompson', items: [{productId: 'PROD003', name: 'Organic Coffee Beans', quantity: 2, price: 24.99}], total: 49.98, status: 'shipped', orderDate: new Date('2024-11-20')}
]);
"

# Verify databases were created
echo -e "${YELLOW}Verifying databases...${NC}"
kubectl exec "$MONGO_POD" -- mongosh -u admin -p "$ROOT_PASSWORD" --authenticationDatabase admin --eval "
db.adminCommand('listDatabases').databases.forEach(function(database) {
    if (database.name !== 'admin' && database.name !== 'config' && database.name !== 'local') {
        print('✓ Database: ' + database.name + ' (' + (database.sizeOnDisk/1024/1024).toFixed(2) + ' MB)');
    }
});
"

# Show collection counts
echo -e "${YELLOW}Collection summary:${NC}"
kubectl exec "$MONGO_POD" -- mongosh -u admin -p "$ROOT_PASSWORD" --authenticationDatabase admin learningdb --eval "
print('learningdb collections:');
print('  - students: ' + db.students.countDocuments());
print('  - courses: ' + db.courses.countDocuments());
"

kubectl exec "$MONGO_POD" -- mongosh -u admin -p "$ROOT_PASSWORD" --authenticationDatabase admin ecommerce --eval "
print('ecommerce collections:');
print('  - products: ' + db.products.countDocuments());
print('  - customers: ' + db.customers.countDocuments());
print('  - orders: ' + db.orders.countDocuments());
"

# Show access information
WEBUI_PASSWORD=$("$SCRIPT_DIR/manage-credentials.sh" --get webui_password)

echo
echo -e "${GREEN}✅ Sample databases created successfully!${NC}"
echo
echo -e "${BLUE}MongoDB Express Access:${NC}"
echo "  URL: http://localhost:8081"
echo "  Username: admin"
echo "  Password: $WEBUI_PASSWORD"
echo
echo -e "${BLUE}Databases Created:${NC}"
echo "  📚 learningdb - Educational data (students, courses)"
echo "  🛒 ecommerce - Business data (products, customers, orders)"
echo
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Open http://localhost:8081 in your browser"
echo "  2. Login with the credentials above"
echo "  3. Click on 'learningdb' or 'ecommerce' in the left sidebar"
echo "  4. Explore collections and documents"
echo "  5. Try editing documents or running queries"
echo
