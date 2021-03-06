#include <solvers/NavierStokes/kernels/fluidStructureInteraction.h>

namespace kernels
{

__global__
void vorticityInducedVibrationsSC(real *vBk, real *vB, real *y, real *ykp1, real forcey, real Mred, real Ured, real Cy, real dt, real alpha_)
{
	const int i = threadIdx.x + (blockDim.x * blockIdx.x);
	
	//calculate new body velocity
	vBk[i] = alpha_*((vB[i] + dt*Cy/(2.0*Mred) - dt*4*3.14159*3.14159*y[0]/(Ured*Ured) - dt*dt*2.0*3.14159*3.14159*vB[i]/(Ured*Ured))  / (1.0 + dt*dt*2*3.14159*3.14159/(Ured*Ured))) +(1-alpha_)*vBk[i];
	
	//calculate new body position
	ykp1[i] = y[i] + (vBk[i] + vB[i])*0.5*dt;

	//first order forward euler
	//vBk[i] = alpha_*(dt*Cy/(2.0*Mred) -dt * 4 * 3.14159 * 3.14159 * y[0] / (Ured * Ured) + vB[i]) + (1-alpha_) * vBk[i];
	//ykp1[i] = y[i] + dt*vB[i];
}

__global__
void vorticityInducedVibrationsLC(real *vBk, real *vB, real *y, real *ykp1, real forcey, real Mred, real Ured, real Cy, real dt)
{
	const int i = threadIdx.x + (blockDim.x * blockIdx.x);

	//calculate new body velocity
	vBk[i] = (vB[i] + dt*Cy/(2.0*Mred) - dt*4*3.14159*3.14159*y[0]/(Ured*Ured) - dt*dt*2.0*3.14159*3.14159*vB[i]/(Ured*Ured))  / (1.0 + dt*dt*2*3.14159*3.14159/(Ured*Ured));

	//calculate new body position
	ykp1[i] = y[i] + (vBk[i] + vB[i])*0.5*dt;
}

__global__
void freeXYSC()
{
	//NSWithBody<memoryType>::B.uBkp1[i] = alpha_*(NSWithBody<memoryType>::B.uB[i] + ratio*dt*(forcex)) + (1-alpha_)*NSWithBody<memoryType>::B.uBk[i];
	//NSWithBody<memoryType>::B.vBkp1[i] = alpha_*(NSWithBody<memoryType>::B.vB[i] + ratio*dt*(forcey)) + (1-alpha_)*NSWithBody<memoryType>::B.vBk[i];
	//NSWithBody<memoryType>::B.vBkp1[i] = alpha_*(NSWithBody<memoryType>::B.vB[i] + dt*(Cy/(2*Mred)-4*3.14159*3.14159*NSWithBody<memoryType>::B.y[0]/(Ured*Ured))) + (1-alpha_)*NSWithBody<memoryType>::B.vBk[i];
}

__global__
void freeXYLC()
{
	//NSWithBody<memoryType>::B.uBk[i] = NSWithBody<memoryType>::B.uB[i] + ratio*dt*forcex;
	//NSWithBody<memoryType>::B.uBkp1[i] = NSWithBody<memoryType>::B.uB[i] + ratio*dt*(forcex);
	//new position
	//NSWithBody<memoryType>::B.xk[i] = NSWithBody<memoryType>::B.x[i] + (NSWithBody<memoryType>::B.uB[i]+NSWithBody<memoryType>::B.uBkp1[i])*dt*0.5;
	//NSWithBody<memoryType>::B.yk[i] = NSWithBody<memoryType>::B.y[i] + (NSWithBody<memoryType>::B.vB[i]+NSWithBody<memoryType>::B.vBkp1[i])*dt*0.5;
}

__global__
void checkConvergencePosition(real tol, bool *flag, real *yk, real *ykp1)
{
	const int i = threadIdx.x + (blockDim.x * blockIdx.x);

	//check if yi is out of tolerance
	if ((ykp1[i] - yk[i]) >= tol)
		flag[0] = false;
	if ((yk[i] - ykp1[i]) >= tol)
		flag[0] = false;
	//update yk
	yk[i] = ykp1[i];
}

__global__
void checkConvergencePositionDF(real tol, bool *flag, real *y, real *ykp1)
{
	const int i = threadIdx.x + (blockDim.x * blockIdx.x);

	//check if yi is out of tolerance
	if ((ykp1[i] - y[i]) >= tol)
		flag[0] = false;
	if ((y[i] - ykp1[i]) >= tol)
		flag[0] = false;
	//update yk
	y[i] = ykp1[i];
}







}
