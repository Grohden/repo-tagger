import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/tagger/repository_tagger_client.dart';
import '../../../router.dart';
import '../../../services/session_service.dart';
import '../../atoms/standard_spacing.dart';
import '../../molecules/primary_raised_button.dart';
import '../../templates/page_body.dart';
import '../../utils/form_controller.dart';

part 'login_bindings.dart';

part 'login_controller.dart';

String _required(String value) {
  if (value.isNullOrBlank) {
    return 'This field must not be empty';
  }

  return null;
}

class LoginPage extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return GetX(
      init: controller,
      builder: (_) => Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Log in Repo Tagger', style: text.headline4),
              PageBody(
                child: _buildForm(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: controller.formKey,
      autovalidate: controller.autoValidate.value,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
            controller: controller.userNameController,
            decoration: const InputDecoration(labelText: 'User'),
            keyboardType: TextInputType.emailAddress,
            validator: _required,
          ),
          StandardSpacing(),
          TextFormField(
            controller: controller.passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            onFieldSubmitted: (value) => controller.submit(),
            validator: _required,
          ),
          StandardSpacing(),
          _renderSubmitButton(context),
          StandardSpacing(),
          StandardSpacing(),
          _renderSignUpButton(context),
        ],
      ),
    );
  }

  Widget _renderSubmitButton(BuildContext context) {
    final loading = controller.showLoading.value;

    return Row(
      children: <Widget>[
        Expanded(
          child: AbsorbPointer(
            absorbing: loading,
            child: PrimaryRaisedButton(
              showLoader: loading,
              child: const Text('Login'),
              onPressed: controller.submit,
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderSignUpButton(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.button;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text("Doesn't have an account?"),
        FlatButton(
          visualDensity: VisualDensity.compact,
          child: Text(
            'Register here',
            style: style.copyWith(
              color: theme.accentColor,
              decoration: TextDecoration.underline,
            ),
          ),
          onPressed: controller.register,
        ),
      ],
    );
  }
}
