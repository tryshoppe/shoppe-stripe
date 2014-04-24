# Stripe Shoppe Module

This module helps with including Stripe within your Shoppe application. The 
information below explains how to get this module installed within your Rails
application.

## Getting Started

This document includes a short tutorial about how to set up this module within your
Shoppe store. If you have any questions, please just
[let me know](http://twitter.com/adamcooke).

### Installing

To install the Shoppe Stripe module, just add it to your Gemfile and run `bundle`.

```ruby
gem 'shoppe-stripe', :require => 'shoppe/stripe'
```

### Configurating

One the gem has been included, you can add your Stripe configuration details through the
Settings page in the Shoppe admin interface.

### Setting up javascript

The module comes with a jQuery form handler which requires jQuery.

In your `application.js` file you should include the Shoppe Stripe form handler as
shown below:

```
#= require shoppe/stripe/form_handler
```

Also, on your payment page, you should call the `shoppe_stripe_javascript` helper to
include the Stripe.js document and set your Stripe API key. 

### Setting up your payment form

Stripe works by submitting cards details submitted by your users to their servers using
javascript before your form is submitted to your server. This means you don't need
to worry too much about PCI compliance. Instead of card details, your server will
simply receive a token which can be used with the Stripe API to take payments later.

To make this work, you need to create a payment form to request card details from your
customer. This module includes the nessessary javascript to handle the submission of
the data to Stripe and will present a token to the form's action URL automatically.

When creating the form, you should tag all fields which contain information which
should be sent to stripe with the `data-stripe` attribute. It should include one of the
following values. The address information is only needed if you want to perform extra
fraud checks.

* number (required)
* exp_month (required)
* exp_year (required)
* cvc
* address_line1
* address_line2
* address_city
* address_state
* address_zip
* address_country

In addition to fields for card details, you should also include a hidden field with the
`token` value in the `data-stripe` attribute.

```html
<form action='/payment' method='post' class='stripeForm'>
  <input type='hidden' name='stripe_token' data-stripe='token' />
  <input type='text' data-stripe='number' placeholder='XXXX XXXX XXXX XXXX'>
  <input type='text' data-stripe='exp_month' placeholder='MM'>
  <input type='text' data-stripe='exp_year' placeholder='YYYY'>
  <input type="submit" value="Continue">
</form>
```

The example above will display fields for number & expiry plus a submit button.
However, the endpoint (/payment) will simply receive a `stripe_token` parameter which
will contain a token which must be 

### Receiving your payment token

Once your user's card details have been exchanged for a token, it will be inserted
into the hidden field on your form and submitted to you as normal.

The endpoint which receives this token must now exchange it for a "customer token".
The module includes the method needed to handle the exchange and store it along with
your order.

```ruby
def payment
  @order = Shoppe::Order.find(session[:current_order_id])
  if request.post?
    if @order::accept_stripe_token(params[:stripe_token])
      redirect_to checkout_confirmation_path
    else
      flash.now[:notice] = "Could not exchange Stripe token. Please try again."
    end
  end
end
```

The `Shoppe::Order#accept_stripe_token` method will save a property on your order 
called `stripe_customer_token` which will be used when the order is confirmed to take
your payment automatically.

Once complete, your Stripe integration is complete. Well done.

## How the module works with your orders

The Stripe module inserts itself into the orderflow in the following ways:

* On order confirmation, the module will automatically authorise a payment from the
  customer's card which was set up earlier. At this point the order will be marked
  as paid. The payment reference will be set to the Stripe charge ID.

* On order acceptance, the module will "capture" the payment which was authorised 
  in the confirmation step.

* On order rejection, the module will "refund" the payment which was authorised in the
  confirmation step.  
