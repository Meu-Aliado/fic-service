-- CreateEnum
CREATE TYPE "fic"."TipoEntidadFinanciera" AS ENUM ('BANCO', 'FIDUCIARIA', 'COMISIONISTA', 'SIMULADA');

-- CreateEnum
CREATE TYPE "fic"."FicCategoria" AS ENUM ('RENTA_FIJA', 'RENTA_VARIABLE', 'BALANCEADO', 'MERCADO_MONETARIO', 'ESTRUCTURADO', 'ETF');

-- CreateEnum
CREATE TYPE "fic"."FicLiquidez" AS ENUM ('DIARIA', 'SEMANAL', 'QUINCENAL', 'MENSUAL', 'TRIMESTRAL');

-- CreateEnum
CREATE TYPE "fic"."FicOrdenTipo" AS ENUM ('APERTURA', 'APORTE', 'REDENCION', 'TRASPASO');

-- CreateEnum
CREATE TYPE "fic"."FicOrdenEstado" AS ENUM ('BORRADOR', 'PENDIENTE_DOCS', 'EN_VALIDACION', 'LISTA_ENVIO', 'ENVIADA', 'APROBADA', 'RECHAZADA', 'CANCELADA');

-- CreateEnum
CREATE TYPE "fic"."FicCuentaEstado" AS ENUM ('PENDIENTE', 'ACTIVA', 'INACTIVA', 'BLOQUEADA', 'CERRADA');

-- CreateEnum
CREATE TYPE "fic"."FicTransaccionTipo" AS ENUM ('APORTE', 'REDENCION', 'VALORIZACION', 'AJUSTE', 'REINVERSION');

-- CreateTable
CREATE TABLE "fic"."entidad_financiera" (
    "id" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "tipo_entidad" "fic"."TipoEntidadFinanciera" NOT NULL,
    "codigo_super" TEXT,
    "pais" TEXT NOT NULL,
    "canal_integracion" TEXT,
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizado_en" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "entidad_financiera_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fic"."fic_fondo" (
    "id" TEXT NOT NULL,
    "entidad_id" TEXT NOT NULL,
    "codigo" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "categoria" "fic"."FicCategoria" NOT NULL,
    "descripcion" TEXT,
    "valor_cuota" DECIMAL(65,30),
    "minimo_apertura" DECIMAL(65,30) NOT NULL,
    "comision_gestion" DECIMAL(65,30),
    "liquidez" "fic"."FicLiquidez" NOT NULL,
    "moneda" TEXT NOT NULL DEFAULT 'COP',
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizado_en" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "fic_fondo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fic"."perfil_riesgo" (
    "id" TEXT NOT NULL,
    "usuario_id" TEXT NOT NULL,
    "metodologia" TEXT NOT NULL,
    "fecha_evaluacion" TIMESTAMP(3) NOT NULL,
    "nivel" TEXT NOT NULL,
    "objetivos_inversion" TEXT,
    "tolerancia_perdida" TEXT,
    "observaciones" TEXT,
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "perfil_riesgo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fic"."fic_cuenta" (
    "id" TEXT NOT NULL,
    "usuario_id" TEXT NOT NULL,
    "fondo_id" TEXT NOT NULL,
    "numero_cuenta_externa" TEXT,
    "fecha_apertura" TIMESTAMP(3) NOT NULL,
    "saldo_cuotas" DECIMAL(65,30) NOT NULL DEFAULT 0,
    "saldo_pesos" DECIMAL(65,30) NOT NULL DEFAULT 0,
    "estado" "fic"."FicCuentaEstado" NOT NULL,
    "orden_apertura_id" TEXT,
    "cerrada_en" TIMESTAMP(3),
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizado_en" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "fic_cuenta_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fic"."fic_orden" (
    "id" TEXT NOT NULL,
    "usuario_id" TEXT NOT NULL,
    "fondo_id" TEXT NOT NULL,
    "perfil_riesgo_id" TEXT,
    "tipo" "fic"."FicOrdenTipo" NOT NULL,
    "moneda" TEXT NOT NULL DEFAULT 'COP',
    "monto" DECIMAL(65,30) NOT NULL,
    "estado" "fic"."FicOrdenEstado" NOT NULL,
    "documento_formulario_id" TEXT,
    "nota" TEXT,
    "fecha_envio" TIMESTAMP(3),
    "fecha_decision" TIMESTAMP(3),
    "razon_rechazo" TEXT,
    "cuenta_destino" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "fic_orden_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fic"."fic_transaccion" (
    "id" TEXT NOT NULL,
    "cuenta_id" TEXT NOT NULL,
    "orden_id" TEXT,
    "tipo" "fic"."FicTransaccionTipo" NOT NULL,
    "monto_cuotas" DECIMAL(65,30),
    "monto_pesos" DECIMAL(65,30) NOT NULL,
    "moneda" TEXT NOT NULL DEFAULT 'COP',
    "fecha_valor" TIMESTAMP(3) NOT NULL,
    "referencia_externa" TEXT,
    "documento_soporte_id" TEXT,
    "saldo_cuotas_posterior" DECIMAL(65,30),
    "saldo_pesos_posterior" DECIMAL(65,30) NOT NULL,
    "descripcion" TEXT,
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "fic_transaccion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fic"."integracion_evento" (
    "id" TEXT NOT NULL,
    "objeto_id" TEXT NOT NULL,
    "objeto_tipo" TEXT NOT NULL,
    "tipo_evento" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "estado_envio" TEXT NOT NULL,
    "enviado_en" TIMESTAMP(3),
    "reintentos" INTEGER NOT NULL DEFAULT 0,
    "ultimo_error" TEXT,
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizado_en" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "integracion_evento_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "entidad_financiera_nombre_pais_key" ON "fic"."entidad_financiera"("nombre", "pais");

-- CreateIndex
CREATE UNIQUE INDEX "fic_fondo_entidad_id_codigo_key" ON "fic"."fic_fondo"("entidad_id", "codigo");

-- CreateIndex
CREATE INDEX "perfil_riesgo_usuario_id_idx" ON "fic"."perfil_riesgo"("usuario_id");

-- CreateIndex
CREATE UNIQUE INDEX "fic_cuenta_orden_apertura_id_key" ON "fic"."fic_cuenta"("orden_apertura_id");

-- CreateIndex
CREATE INDEX "fic_cuenta_usuario_id_idx" ON "fic"."fic_cuenta"("usuario_id");

-- CreateIndex
CREATE INDEX "fic_orden_usuario_id_idx" ON "fic"."fic_orden"("usuario_id");

-- CreateIndex
CREATE INDEX "fic_transaccion_cuenta_id_idx" ON "fic"."fic_transaccion"("cuenta_id");

-- CreateIndex
CREATE INDEX "integracion_evento_estado_envio_idx" ON "fic"."integracion_evento"("estado_envio");

-- AddForeignKey
ALTER TABLE "fic"."fic_fondo" ADD CONSTRAINT "fic_fondo_entidad_id_fkey" FOREIGN KEY ("entidad_id") REFERENCES "fic"."entidad_financiera"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fic"."fic_cuenta" ADD CONSTRAINT "fic_cuenta_fondo_id_fkey" FOREIGN KEY ("fondo_id") REFERENCES "fic"."fic_fondo"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fic"."fic_cuenta" ADD CONSTRAINT "fic_cuenta_orden_apertura_id_fkey" FOREIGN KEY ("orden_apertura_id") REFERENCES "fic"."fic_orden"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fic"."fic_orden" ADD CONSTRAINT "fic_orden_fondo_id_fkey" FOREIGN KEY ("fondo_id") REFERENCES "fic"."fic_fondo"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fic"."fic_orden" ADD CONSTRAINT "fic_orden_perfil_riesgo_id_fkey" FOREIGN KEY ("perfil_riesgo_id") REFERENCES "fic"."perfil_riesgo"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fic"."fic_transaccion" ADD CONSTRAINT "fic_transaccion_cuenta_id_fkey" FOREIGN KEY ("cuenta_id") REFERENCES "fic"."fic_cuenta"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fic"."fic_transaccion" ADD CONSTRAINT "fic_transaccion_orden_id_fkey" FOREIGN KEY ("orden_id") REFERENCES "fic"."fic_orden"("id") ON DELETE SET NULL ON UPDATE CASCADE;
