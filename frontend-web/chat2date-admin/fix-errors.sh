#!/bin/bash

# Chat2Date Admin - Troubleshooting Script
# This script helps fix common development errors

echo "🔧 Chat2Date Admin - Troubleshooting Script"
echo "============================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in the correct directory
if [ ! -f "package.json" ]; then
    print_error "package.json not found!"
    print_info "Please run this script from the chat2date-admin directory"
    exit 1
fi

echo "Select an option:"
echo "1. Clear cache and reinstall (Most Common Fix)"
echo "2. Fix port 5173 already in use"
echo "3. Fix localStorage error (Vue DevTools)"
echo "4. Update all packages"
echo "5. Complete clean reinstall"
echo "6. Fix build errors"
echo "7. Install Lucide icons"
echo "8. Run diagnostics"
echo "9. Exit"
echo ""
read -p "Enter option (1-9): " option

case $option in
    1)
        print_info "Clearing cache and reinstalling packages..."

        # Remove cache
        print_info "Removing Vite cache..."
        rm -rf node_modules/.vite

        # Reinstall
        print_info "Reinstalling packages..."
        npm install

        print_success "Cache cleared and packages reinstalled!"
        print_info "Now run: npm run dev"
        ;;

    2)
        print_info "Checking for processes on port 5173..."

        # Find and kill process on port 5173
        PID=$(lsof -ti:5173)

        if [ -z "$PID" ]; then
            print_warning "No process found on port 5173"
        else
            print_info "Found process $PID on port 5173"
            print_info "Killing process..."
            kill -9 $PID
            print_success "Process killed!"
        fi

        print_info "You can now run: npm run dev"
        ;;

    3)
        print_info "Fixing Vue DevTools localStorage error..."

        # Check if vite.config.js exists
        if [ -f "vite.config.js" ]; then
            print_info "Updating vite.config.js..."

            # Backup original
            cp vite.config.js vite.config.js.backup

            # Comment out vue-devtools
            sed -i.bak "s/import vueDevTools from 'vite-plugin-vue-devtools'/\/\/ import vueDevTools from 'vite-plugin-vue-devtools'/" vite.config.js
            sed -i.bak "s/vueDevTools(),/\/\/ vueDevTools(),/" vite.config.js

            rm -f vite.config.js.bak

            print_success "vite.config.js updated!"
            print_info "Backup saved as vite.config.js.backup"
        else
            print_error "vite.config.js not found!"
        fi

        print_info "Now run: npm run dev"
        ;;

    4)
        print_info "Updating all packages..."

        print_warning "This will update packages to latest versions"
        read -p "Continue? (y/n): " confirm

        if [ "$confirm" = "y" ]; then
            npm update
            print_success "Packages updated!"
        else
            print_info "Update cancelled"
        fi
        ;;

    5)
        print_warning "⚠️  COMPLETE CLEAN REINSTALL ⚠️"
        print_info "This will delete node_modules and reinstall everything"
        read -p "Are you sure? (y/n): " confirm

        if [ "$confirm" = "y" ]; then
            print_info "Removing node_modules..."
            rm -rf node_modules

            print_info "Removing package-lock.json..."
            rm -f package-lock.json

            print_info "Removing cache..."
            rm -rf node_modules/.vite
            rm -rf .vite

            print_info "Installing packages (this may take a few minutes)..."
            npm install

            print_success "Complete clean reinstall done!"
            print_info "Now run: npm run dev"
        else
            print_info "Clean reinstall cancelled"
        fi
        ;;

    6)
        print_info "Fixing build errors..."

        # Clear build directory
        print_info "Removing dist directory..."
        rm -rf dist

        # Clear cache
        print_info "Clearing cache..."
        rm -rf node_modules/.vite

        # Run build
        print_info "Running build..."
        npm run build

        if [ $? -eq 0 ]; then
            print_success "Build successful!"
        else
            print_error "Build failed. Check errors above."
        fi
        ;;

    7)
        print_info "Installing Lucide Icons..."

        npm install lucide-vue-next

        if [ $? -eq 0 ]; then
            print_success "Lucide Icons installed!"
            print_info "You can now use beautiful icons in your app"
        else
            print_error "Installation failed"
        fi
        ;;

    8)
        print_info "Running diagnostics..."
        echo ""

        # Check Node version
        print_info "Node.js version:"
        node --version
        echo ""

        # Check npm version
        print_info "npm version:"
        npm --version
        echo ""

        # Check if package.json exists
        if [ -f "package.json" ]; then
            print_success "package.json found"
        else
            print_error "package.json not found!"
        fi

        # Check if node_modules exists
        if [ -d "node_modules" ]; then
            print_success "node_modules directory exists"
        else
            print_warning "node_modules not found - run npm install"
        fi

        # Check port 5173
        print_info "Checking port 5173..."
        if lsof -Pi :5173 -sTCP:LISTEN -t >/dev/null ; then
            print_warning "Port 5173 is in use"
        else
            print_success "Port 5173 is available"
        fi

        # Check for common files
        echo ""
        print_info "Checking project files..."

        files=("vite.config.js" "src/main.js" "src/App.vue" "index.html")
        for file in "${files[@]}"; do
            if [ -f "$file" ]; then
                print_success "$file exists"
            else
                print_error "$file missing!"
            fi
        done

        echo ""
        print_info "Diagnostics complete!"
        ;;

    9)
        print_info "Exiting..."
        exit 0
        ;;

    *)
        print_error "Invalid option"
        exit 1
        ;;
esac

echo ""
print_success "Done! 🎉"
echo ""
echo "Common commands:"
echo "  npm run dev      - Start development server"
echo "  npm run build    - Build for production"
echo "  npm run preview  - Preview production build"
echo "  npm run lint     - Lint code"
echo ""
