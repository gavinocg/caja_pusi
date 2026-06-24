<?php
require_once ROOT_PATH . '/app/helpers/EmailHelper.php';
class AuthController extends BaseController {

    public function index() {
        $this->login();
    }

    public function login() {
        if ($this->auth->isLoggedIn() && $this->auth->is2FAVerified()) {
            $this->redirect($this->auth->getDashboardURL());
        }

        $error = '';
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->validateCSRF();
            $cedula = trim($_POST['cedula'] ?? '');
            $password = $_POST['password'] ?? '';

            if (empty($cedula) || empty($password)) {
                $error = 'Todos los campos son obligatorios';
            } else {
                $loginResult = $this->auth->login($cedula, $password);
                if ($loginResult === 'activar') {
                    $error = 'Tu cuenta aún no está activada. Revisa tu correo para el enlace de activación.';
                } elseif ($loginResult === true) {
                    if (!empty($_SESSION['cambio_contrasena_obligatorio'])) {
                        $this->redirect('/password?forzado=1');
                    }
                    if ($_SESSION['2fa_required']) {
                        $pin = $this->auth->generarPIN();
                        $this->enviarPINCorreo($pin);
                        $this->redirect('/login/2fa');
                    }
                    $_SESSION['2fa_verified'] = true;
                    $this->redirect($this->auth->getDashboardURL());
                } else {
                    $error = 'Credenciales incorrectas o usuario bloqueado';
                }
            }
        }

        $this->render('auth/login', ['titulo' => 'Iniciar sesión', 'error' => $error]);
    }

    public function _2fa() {
        if (!$this->auth->isLoggedIn()) {
            $this->redirect('/login');
        }
        if ($this->auth->is2FAVerified()) {
            $this->redirect($this->auth->getDashboardURL());
        }

        $error = '';
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->validateCSRF();
            $pin = $_POST['pin'] ?? '';
            if ($this->auth->verificarPIN($pin)) {
                $this->redirect($this->auth->getDashboardURL());
            } else {
                $error = 'PIN incorrecto o expirado';
            }
        }

        $this->render('auth/2fa', ['titulo' => 'Verificación 2FA', 'error' => $error]);
    }

    public function reenviarPIN() {
        if (!$this->auth->isLoggedIn()) {
            $this->json(['error' => 'No autenticado'], 401);
        }
        if (!$this->auth->puedeReenviarPIN()) {
            $this->json(['error' => 'Has excedido el límite de reenvíos'], 429);
        }
        $pin = $this->auth->generarPIN();
        $this->enviarPINCorreo($pin);
        $this->json(['mensaje' => 'PIN reenviado']);
    }

    public function password() {
        $this->requireAuth();
        $errors = [];
        $forzado = !empty($_GET['forzado']);

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->validateCSRF();
            $actual = $_POST['actual'] ?? '';
            $nueva = $_POST['nueva'] ?? '';
            $confirmar = $_POST['confirmar'] ?? '';

            if (empty($actual)) $errors['actual'] = 'Ingrese su contrasena actual';
            if (strlen($nueva) < 6) $errors['nueva'] = 'Mínimo 6 caracteres';
            if ($nueva !== $confirmar) $errors['confirmar'] = 'Las contrasenas no coinciden';

            if (empty($errors)) {
                $stmt = $this->db->prepare("SELECT contrasena FROM usuarios WHERE id_usuario = ?");
                $stmt->execute([$_SESSION['usuario_id']]);
                $hash = $stmt->fetchColumn();

                if (!password_verify($actual, $hash)) {
                    $errors['actual'] = 'Contraseña actual incorrecta';
                } else {
                    $stmt = $this->db->prepare("UPDATE usuarios SET contrasena = ?, fecha_contrasena = NOW() WHERE id_usuario = ?");
                    $stmt->execute([password_hash($nueva, PASSWORD_BCRYPT), $_SESSION['usuario_id']]);
                    unset($_SESSION['cambio_contrasena_obligatorio']);
                    $errors['exito'] = 'Contraseña actualizada correctamente';
                }
            }
        }

        $this->render('auth/password', ['titulo' => 'Cambiar contrasena', 'errors' => $errors, 'forzado' => $forzado]);
    }

    public function olvide() {
        if ($this->auth->isLoggedIn() && $this->auth->is2FAVerified()) {
            $this->redirect($this->auth->getDashboardURL());
        }

        $error = '';
        $exito = '';
        $cedula = '';

        if (!empty($_GET['bloqueado'])) {
            $error = 'Demasiados intentos fallidos. Solicita un nuevo PIN.';
        }

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->validateCSRF();
            $cedula = trim($_POST['cedula'] ?? '');

            if (empty($cedula)) {
                $error = 'Ingresa tu cédula';
            } else {
                $stmt = $this->db->prepare("SELECT id_usuario, nombres, apellidos, correo_electronico, token_activacion FROM usuarios WHERE cedula = ? AND activo = TRUE");
                $stmt->execute([$cedula]);
                $user = $stmt->fetch();

                if (!$user) {
                    $error = 'No se encontró una cuenta activa con esa cédula';
                } elseif ($user['token_activacion'] !== null) {
                    $error = 'Tu cuenta aún no está activada. Revisa tu correo de bienvenida.';
                } elseif (empty($user['correo_electronico'])) {
                    $error = 'No tienes un correo registrado. Contacta al administrador.';
                } else {
                    // Rate limiting: check if user already has a pending non-expired PIN
                    $stmtChk = $this->db->prepare("SELECT reset_token_expira FROM usuarios WHERE id_usuario = ? AND reset_token_hash IS NOT NULL AND reset_token_expira > NOW()");
                    $stmtChk->execute([$user['id_usuario']]);
                    if ($stmtChk->fetch()) {
                        $error = 'Ya enviamos un PIN a tu correo. Revisa tu bandeja de entrada o espera a que expire para solicitar uno nuevo.';
                    } else {
                        $pin = str_pad((string)random_int(0, 999999), 6, '0', STR_PAD_LEFT);
                        $pinHash = password_hash($pin, PASSWORD_BCRYPT);
                        $stmt = $this->db->prepare("UPDATE usuarios SET reset_token_hash = ?, reset_token_expira = DATE_ADD(NOW(), INTERVAL ? MINUTE), reset_token_usos = 0 WHERE id_usuario = ?");
                        $stmt->execute([$pinHash, RESET_TOKEN_EXPIRATION_MIN, $user['id_usuario']]);

                        $nombre = $user['nombres'] . ' ' . $user['apellidos'];
                        $enviado = EmailHelper::enviarPIN($user['correo_electronico'], $nombre, $pin);

                        if ($enviado) {
                            $_SESSION['reset_cedula'] = $cedula;
                            $this->redirect('/login/restablecer');
                        } else {
                            $error = 'Error al enviar el correo. Intenta de nuevo.';
                        }
                    }
                }
            }
        }

        $this->render('auth/olvide', ['titulo' => 'Restablecer contrasena', 'error' => $error, 'exito' => $exito, 'cedula' => $cedula]);
    }

    public function restablecer() {
        if ($this->auth->isLoggedIn() && $this->auth->is2FAVerified()) {
            $this->redirect($this->auth->getDashboardURL());
        }

        if (empty($_SESSION['reset_cedula'])) {
            $this->redirect('/login/olvide');
        }

        $cedula = $_SESSION['reset_cedula'];
        $error = '';
        $exito = '';
        $step = $_GET['step'] ?? 'pin';

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->validateCSRF();

            if ($step === 'pin') {
                $pin = trim($_POST['pin'] ?? '');

                // Check session-based brute-force block
                $intentos =& $_SESSION['reset_intentos'];
                if (!isset($intentos)) $intentos = 0;
                if ($intentos >= 3) {
                    $this->db->prepare("UPDATE usuarios SET reset_token_hash = NULL, reset_token_expira = NULL WHERE cedula = ?")->execute([$cedula]);
                    unset($_SESSION['reset_cedula'], $_SESSION['reset_intentos']);
                    $this->redirect('/login/olvide?bloqueado=1');
                }

                if (empty($pin)) $error = 'Ingresa el PIN recibido';
                else {
                    $stmt = $this->db->prepare("SELECT id_usuario, reset_token_hash, reset_token_expira, reset_token_usos FROM usuarios WHERE cedula = ? AND activo = TRUE AND reset_token_hash IS NOT NULL");
                    $stmt->execute([$cedula]);
                    $user = $stmt->fetch();

                    if (!$user || strtotime($user['reset_token_expira']) < time()) {
                        $error = 'El PIN ha expirado. Solicita uno nuevo.';
                        unset($_SESSION['reset_cedula'], $_SESSION['reset_intentos']);
                    } elseif ((int)$user['reset_token_usos'] >= 5) {
                        $error = 'Demasiados intentos. Solicita un nuevo PIN.';
                        $this->db->prepare("UPDATE usuarios SET reset_token_hash = NULL, reset_token_expira = NULL WHERE id_usuario = ?")->execute([$user['id_usuario']]);
                        unset($_SESSION['reset_cedula'], $_SESSION['reset_intentos']);
                    } elseif (password_verify($pin, $user['reset_token_hash'])) {
                        unset($_SESSION['reset_intentos']);
                        $_SESSION['reset_verificado'] = true;
                        $_SESSION['reset_id_usuario'] = $user['id_usuario'];
                        $step = 'nueva';
                    } else {
                        $intentos++;
                        $this->db->prepare("UPDATE usuarios SET reset_token_usos = reset_token_usos + 1 WHERE id_usuario = ?")->execute([$user['id_usuario']]);
                        $error = 'PIN incorrecto. Intento ' . $intentos . ' de 3.';
                    }
                }
            } elseif ($step === 'nueva') {
                if (empty($_SESSION['reset_verificado'])) {
                    $this->redirect('/login/restablecer');
                }
                $password = $_POST['password'] ?? '';
                $confirmar = $_POST['confirmar'] ?? '';
                if (strlen($password) < 6) $error = 'Mínimo 6 caracteres';
                elseif ($password !== $confirmar) $error = 'Las contraseñas no coinciden';
                else {
                    $stmt = $this->db->prepare("UPDATE usuarios SET contrasena = ?, fecha_contrasena = NOW(), reset_token_hash = NULL, reset_token_expira = NULL, reset_token_usos = 0 WHERE id_usuario = ?");
                    $stmt->execute([password_hash($password, PASSWORD_BCRYPT), $_SESSION['reset_id_usuario']]);
                    unset($_SESSION['reset_cedula'], $_SESSION['reset_verificado'], $_SESSION['reset_id_usuario']);
                    $exito = 'Contraseña restablecida correctamente. Ahora puedes iniciar sesión.';
                }
            }
        }

        $this->render('auth/restablecer', ['titulo' => 'Restablecer contrasena', 'error' => $error, 'exito' => $exito, 'step' => $step, 'cedula' => $cedula]);
    }

    public function logout() {
        $this->auth->logout();
    }

    private function enviarPINCorreo($pin) {
        $to = $_SESSION['usuario_correo'] ?? '';
        if (empty($to)) {
            $db = Database::getInstance();
            $stmt = $db->prepare("SELECT correo_electronico FROM usuarios WHERE id_usuario = ?");
            $stmt->execute([$_SESSION['usuario_id']]);
            $to = $stmt->fetchColumn();
        }
        $nombre = $_SESSION['usuario_nombres'] . ' ' . ($_SESSION['usuario_apellidos'] ?? '');
        EmailHelper::enviarPIN($to, $nombre, $pin);
    }
}
