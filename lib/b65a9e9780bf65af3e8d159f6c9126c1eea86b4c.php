<?php $__env->startSection('content'); ?>

    <?php if(!$settings['cloud']['dropdown']['S3']['children']['bucket']['value']): ?>
    <div class="alert-update alert alert-warning" role="alert"><a href="https://cloud.kerberos.io/" target="_blank"><?php echo Lang::get('settings.purchase'); ?></a></div>
    <?php endif; ?>

    <div id="page-wrapper">
        <div class="container-fluid">
            <div class="row">
                <div id="machinery-settings" class="col-lg-6">
                    <div id="configuration">
                        <h2><i class="fa fa-industry"></i> Machinery</h2>
                        <label class="configuration-switch switch-light">
                            <input type="checkbox">
                            <span class="well">
                                <span><?php echo e(Lang::get('settings.basic')); ?></span>
                                <span><?php echo e(Lang::get('settings.advanced')); ?></span>
                                <a class="btn btn-primary"></a>
                            </span>
                        </label>
                    </div>

                    <?php echo e(Form::open(array('action' => 'SettingsController@update'))); ?>


                        <!-- Basic View -->
                        <?php echo $__env->make('settings.basic', ['kerberos' => $kerberos], array_except(get_defined_vars(), array('__data', '__path')))->render(); ?>

                        <!-- Advanced view -->
                        <?php echo $__env->make('settings.advanced', ['kerberos' => $kerberos, 'settings' => $settings], array_except(get_defined_vars(), array('__data', '__path')))->render(); ?>

                    <?php echo e(Form::close()); ?>

                </div>

                <div id="web-settings" class="col-lg-6">
                    <div id="configuration">
                        <h2><i class="fa fa-eye"></i> Web</h2>
                        <?php echo e(Form::open(array('action' => 'SettingsController@updateWeb'))); ?>

                            <div class="web-content content">
                                <div id="loading-image-view" class="load4" style="padding:50px 0;">
                                    <div class="loader"></div>
                                </div>
                            </div>
                        <?php echo e(Form::close()); ?>

                    </div>
                </div>
            </div>
            <!-- /.row -->
        </div>
        <!-- /.container-fluid -->
    </div>
    <!-- /#page-wrapper -->

    <script type="text/javascript">
        require([_jsBase + 'main.js'], function(common)
        {
            require(["app/controllers/settings_advanced"], function(SettingsAdvanced){});

            require(["app/controllers/toggleSettings", "app/controllers/settings_basic", "app/controllers/settings_web", "app/controllers/settings_kios", "app/controllers/Cache"], function(toggleSettings, SettingsBasic, SettingsWeb, SettingsKiOS, Cache)
            {
                // First load advanced settings.
                toggleSettings.initialize(function()
                {
                    Cache(_baseUrl + "/api/v1/translate/settings").then(function(translation)
                    {
                        SettingsKiOS.initialize("<?php echo e(isset($kios['autoremoval']) ? $kios['autoremoval'] : 0); ?>", "<?php echo e(isset($kios['forcenetwork']) ? $kios['forcenetwork'] : 0) ; ?>", translation);
                        SettingsWeb.initialize("<?php echo e($kerberos['radius']); ?>", translation);
                        SettingsBasic.initialize(translation);
                    });
                });

                $(".configuration-switch input[type='checkbox']").click(function()
                {
                    // toggle settings
                    var checked = $(this).attr('checked');
                    toggleSettings.setType((checked == undefined) ? 'advanced' : 'basic');
                });
            });
        });
    </script>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('template', array_except(get_defined_vars(), array('__data', '__path')))->render(); ?>
