/*
 * Copyright (c) 2020, NVIDIA CORPORATION. All rights reserved.
 */

#include <errno.h>
#include <stdlib.h>
#include <string.h>

#include "pyxis_sbatch.h"
#include "args.h"

struct plugin_context {
	struct plugin_args *args;
};

static struct plugin_context context = {
	.args = NULL,
};

int pyxis_sbatch_init(spank_t sp, int ac, char **av)
{
	context.args = pyxis_args_register(sp);
	if (context.args == NULL) {
		slurm_error("pyxis: failed to register arguments");
		return (-1);
	}

	int ret = spank_setenv(sp, "PYXIS_CTX_ALLOCATOR", "1", 1);
	slurm_error("init %d\n", ret);

	return (0);
}

int pyxis_sbatch_post_opt(spank_t sp, int ac, char **av)
{
	/* Calling pyxis_args_enabled() for arguments validation */
	pyxis_args_enabled();

	/* Note: doesn't work with --export */
	setenv("PYXIS_TEST", "true", 1);

	/* Seem to work with --export */
	int ret = spank_job_control_setenv(sp, "CTX_ALLOCATOR", "1", 1);
	slurm_error("post_opt %d\n", ret);

	return (0);
}

int pyxis_sbatch_exit(spank_t sp, int ac, char **av)
{
	pyxis_args_free();

	memset(&context, 0, sizeof(context));

	return (0);
}


