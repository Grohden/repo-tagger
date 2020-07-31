import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/tagger/repository_tagger_client.dart';
import '../../../router.dart';
import '../../atoms/standard_input_spacing.dart';
import '../../molecules/primary_raised_button.dart';
import '../../templates/page_body.dart';
import '../../utils/form_controller.dart';

part 'register_bindings.dart';

part 'register_controller.dart';

String _required(String value) {
  if (value.isNullOrBlank) {
    return 'This field must not be empty';
  }

  return null;
}

class RegisterPage extends GetView<RegisterController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
      ),
      body: Center(
        child: PageBody(
          child: _buildForm(context),
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
        children: [
          TextFormField(
            controller: controller.userNameController,
            decoration: const InputDecoration(
              labelText: 'Github user',
              hintText: 'Your github user name',
            ),
            keyboardType: TextInputType.name,
            enableSuggestions: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [
              AutofillHints.nickname,
              AutofillHints.newUsername,
            ],
            validator: _required,
          ),
          StandardInputSpacing(),
          TextFormField(
            controller: controller.displayNameController,
            decoration: const InputDecoration(
              labelText: 'Display name',
              hintText: 'The name that the app will use to refer to you',
            ),
            keyboardType: TextInputType.name,
            enableSuggestions: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [
              AutofillHints.name,
              AutofillHints.newUsername,
            ],
            validator: _required,
          ),
          StandardInputSpacing(),
          TextFormField(
            controller: controller.passwordController,
            decoration: const InputDecoration(hintText: 'Password'),
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            enableSuggestions: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            onFieldSubmitted: (value) => controller.submit(),
            validator: _required,
          ),
          StandardInputSpacing(),
          _renderSubmitButton(context),
          StandardInputSpacing(),
          StandardInputSpacing(),
          _renderLoginButton(context),
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
              child: const Text('Submit'),
              onPressed: controller.submit,
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderLoginButton(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.button;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('Already have an account?'),
        FlatButton(
          visualDensity: VisualDensity.compact,
          child: Text(
            'Login here',
            style: style.copyWith(
              color: theme.accentColor,
              decoration: TextDecoration.underline,
            ),
          ),
          onPressed: controller.openLogin,
        ),
      ],
    );
  }
}
