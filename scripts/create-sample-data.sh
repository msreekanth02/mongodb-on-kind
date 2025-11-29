#!/bin/bash

# MongoDB Sample Data Creator for Learning
# Creates sample databases and collections for educational exploration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_header() {
    echo
    echo -e "${CYAN}${BOLD}================================================================${NC}"
    echo -e "${CYAN}${BOLD}$1${NC}"
    echo -e "${CYAN}${BOLD}================================================================${NC}"
    echo
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓ SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠ WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗ ERROR]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Function to check if MongoDB pod is available
check_mongodb_pod() {
    print_step "Checking MongoDB pod availability..."
    
    if ! kubectl get pods -l app=mongodb --context kind-mongodb-cluster &>/dev/null; then
        print_error "MongoDB pod not found. Please ensure the cluster is running."
        print_info "Run: ./scripts/interactive-menu.sh -> Option 3: Cluster Management -> Start Cluster"
        exit 1
    fi
    
    MONGO_POD=$(kubectl get pods -l app=mongodb --context kind-mongodb-cluster -o jsonpath='{.items[0].metadata.name}')
    if [ -z "$MONGO_POD" ]; then
        print_error "Could not get MongoDB pod name"
        exit 1
    fi
    
    print_success "MongoDB pod found: $MONGO_POD"
}

# Function to get MongoDB credentials
get_credentials() {
    print_step "Retrieving MongoDB credentials..."
    
    if [ ! -f "$SCRIPT_DIR/manage-credentials.sh" ]; then
        print_error "Credential management script not found"
        exit 1
    fi
    
    ROOT_PASSWORD=$("$SCRIPT_DIR/manage-credentials.sh" --get mongodb_root_password 2>/dev/null)
    if [ -z "$ROOT_PASSWORD" ]; then
        print_error "Could not retrieve MongoDB password"
        print_info "Initialize credentials with: ./scripts/manage-credentials.sh --init"
        exit 1
    fi
    
    print_success "Credentials retrieved successfully"
}

# Function to test MongoDB connectivity
test_connection() {
    print_step "Testing MongoDB connection..."
    
    if kubectl exec $MONGO_POD --context kind-mongodb-cluster -- mongosh -u admin -p "$ROOT_PASSWORD" --authenticationDatabase admin --eval "db.runCommand({ping: 1})" &>/dev/null; then
        print_success "MongoDB connection successful"
    else
        print_error "Failed to connect to MongoDB"
        exit 1
    fi
}

# Function to create learning database
create_learning_database() {
    print_header "CREATING LEARNING DATABASE"
    
    print_info "Creating 'learningdb' database with student and course collections..."
    
    kubectl exec $MONGO_POD --context kind-mongodb-cluster -- mongosh -u admin -p "$ROOT_PASSWORD" --authenticationDatabase admin --eval "
    use learningdb;
    
    // Create students collection
    db.students.insertMany([
        {
            _id: ObjectId(),
            studentId: 'STU001',
            name: 'Alice Johnson',
            age: 23,
            email: 'alice.johnson@university.edu',
            course: 'Computer Science',
            year: 3,
            gpa: 3.8,
            courses: ['CS101', 'CS201', 'MATH101'],
            address: {
                street: '123 University Ave',
                city: 'Boston',
                state: 'MA',
                zip: '02115'
            },
            enrollmentDate: new Date('2022-09-01')
        },
        {
            _id: ObjectId(),
            studentId: 'STU002',
            name: 'Bob Smith',
            age: 21,
            email: 'bob.smith@university.edu',
            course: 'Mathematics',
            year: 2,
            gpa: 3.6,
            courses: ['MATH201', 'MATH301', 'PHY101'],
            address: {
                street: '456 College St',
                city: 'Cambridge',
                state: 'MA',
                zip: '02139'
            },
            enrollmentDate: new Date('2023-09-01')
        },
        {
            _id: ObjectId(),
            studentId: 'STU003',
            name: 'Carol Davis',
            age: 22,
            email: 'carol.davis@university.edu',
            course: 'Physics',
            year: 4,
            gpa: 3.9,
            courses: ['PHY301', 'PHY401', 'MATH301'],
            address: {
                street: '789 Science Blvd',
                city: 'Boston',
                state: 'MA',
                zip: '02118'
            },
            enrollmentDate: new Date('2021-09-01')
        }
    ]);
    
    // Create courses collection
    db.courses.insertMany([
        {
            _id: ObjectId(),
            courseCode: 'CS101',
            name: 'Introduction to Programming',
            credits: 3,
            instructor: 'Dr. Smith',
            department: 'Computer Science',
            description: 'Basic programming concepts using Python',
            prerequisites: [],
            maxStudents: 50,
            currentStudents: 45
        },
        {
            _id: ObjectId(),
            courseCode: 'CS201',
            name: 'Data Structures and Algorithms',
            credits: 4,
            instructor: 'Dr. Johnson',
            department: 'Computer Science',
            description: 'Advanced programming with focus on algorithms',
            prerequisites: ['CS101'],
            maxStudents: 40,
            currentStudents: 35
        },
        {
            _id: ObjectId(),
            courseCode: 'MATH201',
            name: 'Calculus II',
            credits: 4,
            instructor: 'Dr. Williams',
            department: 'Mathematics',
            description: 'Integration and infinite series',
            prerequisites: ['MATH101'],
            maxStudents: 60,
            currentStudents: 55
        },
        {
            _id: ObjectId(),
            courseCode: 'PHY301',
            name: 'Quantum Mechanics',
            credits: 3,
            instructor: 'Dr. Brown',
            department: 'Physics',
            description: 'Introduction to quantum physics principles',
            prerequisites: ['PHY201', 'MATH201'],
            maxStudents: 30,
            currentStudents: 25
        }
    ]);
    
    print('Learning database created successfully!');
    print('Collections created:');
    print('- students: ' + db.students.countDocuments());
    print('- courses: ' + db.courses.countDocuments());
    "
    
    print_success "Learning database created successfully!"
}

# Function to create e-commerce database
create_ecommerce_database() {
    print_header "CREATING E-COMMERCE DATABASE"
    
    print_info "Creating 'ecommerce' database with products, customers, and orders..."
    
    kubectl exec $MONGO_POD --context kind-mongodb-cluster -- mongosh -u admin -p "$ROOT_PASSWORD" --authenticationDatabase admin --eval "
    use ecommerce;
    
    // Create products collection
    db.products.insertMany([
        {
            _id: ObjectId(),
            productId: 'PROD001',
            name: 'MacBook Pro 14-inch',
            price: 1999.99,
            category: 'Electronics',
            subcategory: 'Laptops',
            brand: 'Apple',
            stock: 25,
            rating: 4.8,
            reviews: 127,
            description: 'Powerful laptop with M2 chip',
            specifications: {
                processor: 'Apple M2',
                memory: '16GB',
                storage: '512GB SSD',
                display: '14.2-inch Retina'
            },
            tags: ['laptop', 'apple', 'professional', 'creative'],
            dateAdded: new Date('2024-01-15')
        },
        {
            _id: ObjectId(),
            productId: 'PROD002',
            name: 'Kubernetes in Action',
            price: 49.99,
            category: 'Books',
            subcategory: 'Technology',
            brand: 'Manning Publications',
            stock: 50,
            rating: 4.6,
            reviews: 89,
            description: 'Comprehensive guide to Kubernetes',
            specifications: {
                pages: 624,
                format: 'Paperback',
                language: 'English',
                isbn: '9781617293726'
            },
            tags: ['kubernetes', 'devops', 'containers', 'learning'],
            dateAdded: new Date('2024-02-01')
        },
        {
            _id: ObjectId(),
            productId: 'PROD003',
            name: 'MongoDB Coffee Mug',
            price: 15.99,
            category: 'Accessories',
            subcategory: 'Drinkware',
            brand: 'MongoDB Store',
            stock: 100,
            rating: 4.3,
            reviews: 45,
            description: 'Premium ceramic mug with MongoDB logo',
            specifications: {
                material: 'Ceramic',
                capacity: '11oz',
                dishwasher: true,
                microwave: true
            },
            tags: ['mug', 'mongodb', 'office', 'gift'],
            dateAdded: new Date('2024-01-20')
        }
    ]);
    
    // Create customers collection
    db.customers.insertMany([
        {
            _id: ObjectId(),
            customerId: 'CUST001',
            name: 'John Doe',
            email: 'john.doe@email.com',
            phone: '+1-555-0101',
            address: {
                street: '123 Main St',
                city: 'San Francisco',
                state: 'CA',
                zip: '94102',
                country: 'USA'
            },
            preferences: {
                newsletter: true,
                notifications: true,
                categories: ['Electronics', 'Books']
            },
            totalOrders: 5,
            totalSpent: 2599.95,
            loyaltyPoints: 259,
            joinDate: new Date('2023-06-15')
        },
        {
            _id: ObjectId(),
            customerId: 'CUST002',
            name: 'Jane Smith',
            email: 'jane.smith@email.com',
            phone: '+1-555-0202',
            address: {
                street: '456 Oak Ave',
                city: 'Los Angeles',
                state: 'CA',
                zip: '90210',
                country: 'USA'
            },
            preferences: {
                newsletter: false,
                notifications: true,
                categories: ['Books', 'Accessories']
            },
            totalOrders: 3,
            totalSpent: 135.97,
            loyaltyPoints: 13,
            joinDate: new Date('2023-09-22')
        }
    ]);
    
    // Create orders collection
    db.orders.insertMany([
        {
            _id: ObjectId(),
            orderId: 'ORD001',
            customerId: 'CUST001',
            customerName: 'John Doe',
            items: [
                {
                    productId: 'PROD001',
                    productName: 'MacBook Pro 14-inch',
                    quantity: 1,
                    price: 1999.99,
                    total: 1999.99
                }
            ],
            subtotal: 1999.99,
            tax: 159.99,
            shipping: 0.00,
            total: 2159.98,
            status: 'delivered',
            shippingAddress: {
                street: '123 Main St',
                city: 'San Francisco',
                state: 'CA',
                zip: '94102'
            },
            orderDate: new Date('2024-03-01'),
            deliveryDate: new Date('2024-03-05')
        },
        {
            _id: ObjectId(),
            orderId: 'ORD002',
            customerId: 'CUST002',
            customerName: 'Jane Smith',
            items: [
                {
                    productId: 'PROD002',
                    productName: 'Kubernetes in Action',
                    quantity: 1,
                    price: 49.99,
                    total: 49.99
                },
                {
                    productId: 'PROD003',
                    productName: 'MongoDB Coffee Mug',
                    quantity: 2,
                    price: 15.99,
                    total: 31.98
                }
            ],
            subtotal: 81.97,
            tax: 6.56,
            shipping: 9.99,
            total: 98.52,
            status: 'shipped',
            shippingAddress: {
                street: '456 Oak Ave',
                city: 'Los Angeles',
                state: 'CA',
                zip: '90210'
            },
            orderDate: new Date('2024-03-10'),
            estimatedDelivery: new Date('2024-03-15')
        }
    ]);
    
    print('E-commerce database created successfully!');
    print('Collections created:');
    print('- products: ' + db.products.countDocuments());
    print('- customers: ' + db.customers.countDocuments());
    print('- orders: ' + db.orders.countDocuments());
    "
    
    print_success "E-commerce database created successfully!"
}

# Function to display access information
show_access_info() {
    print_header "ACCESS INFORMATION"
    
    # Get current password
    WEBUI_PASSWORD=$("$SCRIPT_DIR/manage-credentials.sh" --get webui_password 2>/dev/null)
    
    echo -e "${GREEN}MongoDB Express Web Interface:${NC}"
    echo "  URL: http://localhost:8081"
    echo "  Username: admin"
    echo "  Password: $WEBUI_PASSWORD"
    echo
    echo -e "${BOLD}Sample Databases Created:${NC}"
    echo "• learningdb - Educational data with students and courses"
    echo "• ecommerce - Business data with products, customers, and orders"
    echo
    echo -e "${BOLD}What to Explore in MongoDB Express:${NC}"
    echo "1. Navigate to each database in the left sidebar"
    echo "2. Click on collections to see the data structure"
    echo "3. Click 'View Documents' to see actual data"
    echo "4. Try editing documents by clicking the 'edit' button"
    echo "5. Use the query interface to filter data"
    echo
    echo -e "${BOLD}Sample Queries to Try:${NC}"
    echo "• Find students with GPA > 3.7: {gpa: {\$gt: 3.7}}"
    echo "• Find products under $50: {price: {\$lt: 50}}"
    echo "• Find courses with 'Computer Science' department: {department: 'Computer Science'}"
    echo "• Find orders with 'shipped' status: {status: 'shipped'}"
    echo
    echo -e "${YELLOW}💡 Learning Tip: Use the MongoDB Express interface to visually explore${NC}"
    echo -e "${YELLOW}   the data structure and understand NoSQL document storage!${NC}"
}

# Function to display learning scenarios
show_learning_scenarios() {
    print_header "LEARNING SCENARIOS"
    
    echo -e "${BOLD}Try these hands-on scenarios in MongoDB Express:${NC}"
    echo
    echo -e "${CYAN}📚 Scenario 1: Student Management${NC}"
    echo "1. Browse the 'learningdb' database"
    echo "2. View the 'students' collection"
    echo "3. Find Alice Johnson's record"
    echo "4. Edit her GPA to 3.9"
    echo "5. Add a new student using the 'New Document' button"
    echo
    echo -e "${CYAN}🛒 Scenario 2: E-commerce Analytics${NC}"
    echo "1. Browse the 'ecommerce' database"
    echo "2. Check total revenue by examining 'orders' collection"
    echo "3. Find the most expensive product in 'products'"
    echo "4. Look at customer purchase history"
    echo
    echo -e "${CYAN}🔍 Scenario 3: Data Relationships${NC}"
    echo "1. Notice how orders reference customers by customerId"
    echo "2. See how students reference courses by courseCode"
    echo "3. Understand the difference between embedded docs (address) and references"
    echo
    echo -e "${CYAN}⚙️ Scenario 4: MongoDB Operations${NC}"
    echo "1. Try the query interface with filters"
    echo "2. Sort results by different fields"
    echo "3. Create indexes for better performance"
    echo "4. Export collection data"
    echo
}

# Main function
main() {
    print_header "MONGODB SAMPLE DATA CREATOR"
    
    echo -e "${GREEN}This script creates sample databases for learning MongoDB and MongoDB Express${NC}"
    echo
    
    # Check prerequisites
    check_mongodb_pod
    get_credentials
    test_connection
    
    # Create sample databases
    create_learning_database
    create_ecommerce_database
    
    # Show access information
    show_access_info
    show_learning_scenarios
    
    print_success "Sample data creation completed!"
    echo
    print_info "Open MongoDB Express at http://localhost:8081 to explore your data"
}

# Show help if requested
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    print_header "MONGODB SAMPLE DATA CREATOR - HELP"
    echo
    echo "Usage: $0 [options]"
    echo
    echo "This script creates sample databases and collections for learning MongoDB."
    echo
    echo "Prerequisites:"
    echo "• MongoDB cluster must be running"
    echo "• Credentials must be initialized"
    echo
    echo "Created Databases:"
    echo "• learningdb - Educational data (students, courses)"
    echo "• ecommerce - Business data (products, customers, orders)"
    echo
    echo "Options:"
    echo "  --help, -h    Show this help message"
    echo
    echo "Example:"
    echo "  $0    # Create sample databases"
    echo
    exit 0
fi

# Run main function
main "$@"
