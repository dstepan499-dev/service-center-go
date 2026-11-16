import './style.css';
import { Login, Logout, ChangePassword } from '../wailsjs/go/main/App';

// Элементы интерфейса
const authScreen = document.getElementById('auth-screen');
const mainScreen = document.getElementById('main-screen');
const loginForm = document.getElementById('login-form');
const usernameInput = document.getElementById('username');
const passwordInput = document.getElementById('password');
const authError = document.getElementById('auth-error');

const userDisplayName = document.getElementById('user-display-name');
const userRoleBadge = document.getElementById('user-role-badge');
const btnLogout = document.getElementById('btn-logout');
const welcomeMessage = document.getElementById('welcome-message');

// Модалки
const modalPass = document.getElementById('modal-password');
const modalAbout = document.getElementById('modal-about');
const btnChangePass = document.getElementById('btn-change-pass');
const btnAbout = document.getElementById('btn-about');

let currentUser = null;

// Названия ролей на русском языке
const roleNames = {
    'director': 'Директор',
    'manager': 'Менеджер по приему',
    'master': 'Мастер-диагност',
    'warehouse': 'Заведующий складом',
    'admin': 'Администратор'
};

// 1. Обработка отправки формы логина
loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    authError.classList.add('hidden');

    const username = usernameInput.value.trim();
    const password = passwordInput.value;

    if (!username || !password) {
        showAuthError('Заполните логин и пароль');
        return;
    }

    try {
        // Вызываем метод Go-бэкенда
        const response = await Login(username, password);

        if (response.success && response.user) {
            currentUser = response.user;
            showMainScreen();
        } else {
            showAuthError(response.message || 'Ошибка входа');
        }
    } catch (err) {
        showAuthError('Ошибка связи с сервером: ' + err);
    }
});

function showAuthError(msg) {
    authError.textContent = msg;
    authError.classList.remove('hidden');
}

// 2. Переключение на главное окно и адаптация меню под роль (RBAC)
function showMainScreen() {
    authScreen.classList.add('hidden');
    mainScreen.classList.remove('hidden');

    userDisplayName.textContent = currentUser.fullName;
    userRoleBadge.textContent = roleNames[currentUser.role] || currentUser.role;
    welcomeMessage.textContent = `Вы авторизованы как «${roleNames[currentUser.role]}». Панель управления адаптирована под ваши права.`;

    applyRolePermissions(currentUser.role);
}

// 3. Адаптивное меню: скрытие/показ разделов в зависимости от роли
function applyRolePermissions(role) {
    const navOrders = document.getElementById('nav-orders');
    const navClients = document.getElementById('nav-clients');
    const navItems = document.getElementById('nav-items');
    const navParts = document.getElementById('nav-parts');
    const navSuppliers = document.getElementById('nav-suppliers');
    const navEmployees = document.getElementById('nav-employees');
    const navDocuments = document.getElementById('nav-documents');
    const navAnalytics = document.getElementById('nav-analytics');

    const secWarehouse = document.getElementById('section-warehouse');
    const secHR = document.getElementById('section-hr');
    const secAnalytics = document.getElementById('section-analytics');

    // Сброс видимости: всё видно
    [navOrders, navClients, navItems, navParts, navSuppliers, navEmployees, navDocuments, navAnalytics, secWarehouse, secHR, secAnalytics]
        .forEach(el => el.classList.remove('hidden'));

    // Применяем ролевые ограничения
    if (role === 'manager') {
        // Менеджер не видит склад, зарплаты/кадры и прямые SQL/аналитику
        navParts.classList.add('hidden');
        navSuppliers.classList.add('hidden');
        secWarehouse.classList.add('hidden');
        navEmployees.classList.add('hidden');
        secHR.classList.add('hidden');
        navDocuments.classList.add('hidden');
        navAnalytics.classList.add('hidden');
        secAnalytics.classList.add('hidden');
    } else if (role === 'master') {
        // Мастер видит только назначенные заказы и запчасти
        navClients.classList.add('hidden');
        navSuppliers.classList.add('hidden');
        navEmployees.classList.add('hidden');
        secHR.classList.add('hidden');
        navDocuments.classList.add('hidden');
        navAnalytics.classList.add('hidden');
        secAnalytics.classList.add('hidden');
    } else if (role === 'warehouse') {
        // Кладовщик видит склад и поставщиков
        navOrders.classList.add('hidden');
        navClients.classList.add('hidden');
        navItems.classList.add('hidden');
        navEmployees.classList.add('hidden');
        secHR.classList.add('hidden');
        navDocuments.classList.add('hidden');
        navAnalytics.classList.add('hidden');
        secAnalytics.classList.add('hidden');
    }
    // director и admin видят всё!
}

// 4. Логика выхода (Logout)
btnLogout.addEventListener('click', async () => {
    await Logout();
    currentUser = null;
    passwordInput.value = '';
    authError.classList.add('hidden');
    mainScreen.classList.add('hidden');
    authScreen.classList.remove('hidden');
});

// 5. Модальные окна
btnAbout.addEventListener('click', () => modalAbout.classList.remove('hidden'));
document.getElementById('btn-close-about').addEventListener('click', () => modalAbout.classList.add('hidden'));
document.getElementById('btn-close-about-modal').addEventListener('click', () => modalAbout.classList.add('hidden'));

btnChangePass.addEventListener('click', () => {
    document.getElementById('old-password').value = '';
    document.getElementById('new-password').value = '';
    const msg = document.getElementById('pass-msg');
    msg.classList.add('hidden');
    modalPass.classList.remove('hidden');
});

document.getElementById('btn-close-pass-modal').addEventListener('click', () => modalPass.classList.add('hidden'));
document.getElementById('btn-cancel-pass').addEventListener('click', () => modalPass.classList.add('hidden'));

document.getElementById('btn-submit-pass').addEventListener('click', async () => {
    const oldP = document.getElementById('old-password').value;
    const newP = document.getElementById('new-password').value;
    const msg = document.getElementById('pass-msg');

    const [success, message] = await ChangePassword(oldP, newP);
    msg.textContent = message;
    msg.className = 'message-banner ' + (success ? 'success' : 'error');
    msg.classList.remove('hidden');

    if (success) {
        setTimeout(() => modalPass.classList.add('hidden'), 1500);
    }
});

// Навигация по вкладкам
document.querySelectorAll('.nav-item').forEach(button => {
    button.addEventListener('click', (e) => {
        document.querySelectorAll('.nav-item').forEach(b => b.classList.remove('active'));
        e.target.classList.add('active');
        const tab = e.target.getAttribute('data-tab');
        document.getElementById('welcome-message').textContent = `Выбран раздел: «${e.target.textContent}». Загрузка данных...`;
    });
});